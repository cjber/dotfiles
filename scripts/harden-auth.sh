#!/usr/bin/env bash
# Enforce authenticated sudo, and optionally wire up Duo phone-push approval.
#
# Why this is a script and not dotter-managed files:
#   - /etc/sudoers must be mode 0440 and root-owned or sudo refuses to read it
#     ("unsafe mode"). Dotter deploys 0644 and has no per-file permission
#     setting.
#   - /etc/duo/pam_duo.conf holds a Duo SECRET KEY. cjber/dotfiles is a PUBLIC
#     repo and .dotter/local-root.toml is tracked, so the secret can live in
#     neither the repo nor a dotter variable. It is written here at 0600 from an
#     argument, and never persisted to the repo.
#
# The PAM stack (/etc/pam.d/sudo) IS dotter-managed - 0644, no secrets.
#
# SAFETY, and the reason this script is so defensive: pam_duo fails OPEN by
# default. duo_unix ships /etc/duo/pam_duo.conf with empty keys and
# failmode=safe, and a missing conf file also fails open. Because pam_duo is
# `sufficient` in our stack, that state authenticates ANY password. Verified
# 2026-07-30 with pamtester run AS ROOT (matching setuid sudo): with the
# packaged failmode=safe a wrong password was ACCEPTED; with failmode=secure the
# same password was rejected. failmode cannot be set from the PAM line
# (pam_duo takes only conf=), so this script:
#   1. always writes the conf with failmode=secure, keys or no keys, so the
#      unconfigured state fails CLOSED; and
#   2. refuses to remove NOPASSWD until pamtester has PROVEN that a wrong
#      password is rejected.
#
# Idempotent: safe to re-run. Re-running without --duo preserves existing keys.
#
# Usage:
#   ~/scripts/harden-auth.sh                      # sudo hardening only
#   ~/scripts/harden-auth.sh --duo IKEY SKEY HOST # also configure phone push
#   ~/scripts/harden-auth.sh --skip-password-check # automation only
set -euo pipefail

SUDOERS=/etc/sudoers
BACKUP=/etc/sudoers.pre-harden.bak
DUO_CONF=/etc/duo/pam_duo.conf
MARKER='# managed by ~/scripts/harden-auth.sh'
SKIP_PW_CHECK=0
DUO_IKEY=""; DUO_SKEY=""; DUO_HOST=""

die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33mwarning:\033[0m %s\n' "$*" >&2; }

while [ $# -gt 0 ]; do
    case $1 in
        --duo)
            [ $# -ge 4 ] || die "--duo needs three values: IKEY SKEY API_HOST"
            DUO_IKEY=$2; DUO_SKEY=$3; DUO_HOST=$4; shift 4 ;;
        --skip-password-check) SKIP_PW_CHECK=1; shift ;;
        -h|--help) sed -n '2,40p' "$0"; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[ "$(id -u)" -ne 0 ] || die "run as your normal user, not root (it needs to know who you are)"
command -v pamtester >/dev/null 2>&1 || die "pamtester is required for the safety gate: paru -S pamtester"

# ---------------------------------------------------------------------------
# 1. Refuse to proceed without a usable password. Removing NOPASSWD with a
#    locked or empty hash is a guaranteed lockout with no way back short of a
#    rescue USB.
# ---------------------------------------------------------------------------
hash=$(sudo getent shadow "$USER" | cut -d: -f2)
case "$hash" in
    ''|'!'*|'*') die "$USER has no usable password hash ('${hash:-empty}'). Run 'passwd' first, or this would lock you out of sudo entirely." ;;
esac
info "password hash present for $USER ($(printf '%s' "$hash" | cut -c1-3)...)"

# ---------------------------------------------------------------------------
# 2. A valid hash is not the same as a remembered password. Force a real
#    authentication before taking NOPASSWD away.
# ---------------------------------------------------------------------------
if [ "$SKIP_PW_CHECK" -eq 0 ]; then
    info "verifying you know your password - enter it below"
    su "$USER" -c true || die "password verification failed. NOTHING has been changed and you still have NOPASSWD sudo. Fix it with 'passwd' and re-run."
    info "password verified"
fi

# ---------------------------------------------------------------------------
# 3. Make the Duo config fail-CLOSED, unconditionally.
#
#    This runs whether or not keys were supplied, precisely because the
#    no-keys state is the dangerous one: the packaged conf ships
#    failmode=safe, which would let pam_duo authenticate anybody.
# ---------------------------------------------------------------------------
sudo install -d -m 0755 -o root -g root /etc/duo

if [ -z "$DUO_IKEY" ] && sudo test -f "$DUO_CONF"; then
    # Preserve existing keys across a re-run; only failmode is re-asserted.
    DUO_IKEY=$(sudo sed -n 's/^[[:space:]]*ikey[[:space:]]*=[[:space:]]*//p' "$DUO_CONF" | head -1)
    DUO_SKEY=$(sudo sed -n 's/^[[:space:]]*skey[[:space:]]*=[[:space:]]*//p' "$DUO_CONF" | head -1)
    DUO_HOST=$(sudo sed -n 's/^[[:space:]]*host[[:space:]]*=[[:space:]]*//p' "$DUO_CONF" | head -1)
    [ -n "$DUO_IKEY" ] && info "preserving existing Duo keys"
fi

sudo install -m 0600 -o root -g root /dev/stdin "$DUO_CONF" <<EOF
[duo]
ikey = $DUO_IKEY
skey = $DUO_SKEY
host = $DUO_HOST

; failmode=secure is MANDATORY here, not a preference. Duo's default is "safe",
; which ALLOWS access on any service or config error. pam_duo is `sufficient` in
; /etc/pam.d/sudo, so fail-open there authenticates any password from any user.
; With empty keys above, "secure" makes the phone path simply unavailable -
; which is the correct, safe, password-only state.
failmode = secure

; Push immediately instead of showing a factor menu.
autopush = yes
prompts = 1
send_gecos = no
EOF

if [ -n "$DUO_IKEY" ]; then
    info "wrote $DUO_CONF (0600 root) with Duo keys, failmode=secure"
else
    info "wrote $DUO_CONF (0600 root) with NO keys, failmode=secure - fails closed"
    warn "the phone path is INERT until you supply keys. Password auth still works. Configure with:"
    warn "    ~/scripts/harden-auth.sh --duo <IKEY> <SKEY> <API_HOST>"
fi

# ---------------------------------------------------------------------------
# 4. Confirm the dotter-managed PAM stack is deployed.
# ---------------------------------------------------------------------------
if ! grep -q 'pam_duo.so' /etc/pam.d/sudo 2>/dev/null; then
    warn "/etc/pam.d/sudo has no pam_duo line. Deploy the root package first:"
    warn "    cd ~/dotfiles && sudo dotter -l .dotter/local-root.toml \\"
    warn "      --cache-file .dotter/cache-root.toml --cache-directory .dotter/cache-root deploy --force"
fi

# ---------------------------------------------------------------------------
# 5. THE SAFETY GATE. Prove a wrong password is rejected before disarming
#    NOPASSWD. Tested against a throwaway PAM service that is a copy of the
#    real one, so a failure here costs nothing.
#
#    This is the check that would have caught the fail-open pam_duo config,
#    and it is why sudoers is not touched until after it passes.
# ---------------------------------------------------------------------------
probe=/etc/pam.d/nebula-harden-probe
sudo install -m 0644 -o root -g root /etc/pam.d/sudo "$probe"
cleanup_probe() { sudo rm -f "$probe"; }
trap cleanup_probe EXIT


# pamtester MUST run under sudo here. Real sudo is setuid root, and pam_duo
# reads its 0600 root-owned conf as root. An unprivileged pamtester cannot read
# that conf at all - so it cannot see failmode either, falls back to pam_duo's
# built-in "safe" default, and reports fail-open on a system that is actually
# fine. Running the gate as the user therefore produces a false alarm.
#
# Verified on 2026-07-30: as root with failmode=secure a wrong password is
# rejected; as root with the packaged failmode=safe it is ACCEPTED. The hole is
# real, and this gate only detects it when run with root's view of the conf.
info "safety gate: checking that a wrong password is REJECTED"
if printf 'this-is-deliberately-the-wrong-password\n' \
        | sudo timeout 90 pamtester "$(basename "$probe")" "$USER" authenticate >/dev/null 2>&1; then
    cleanup_probe
    die "SAFETY GATE FAILED: a wrong password was ACCEPTED by the sudo PAM stack.
     sudoers has NOT been changed - you are still on NOPASSWD, which is bad but
     not as bad as a sudo that accepts anything.
     Almost certainly a fail-open pam_duo: check that $DUO_CONF says
     'failmode = secure' and is readable by root only, then re-run."
fi
info "safety gate passed: wrong password rejected"
cleanup_probe
trap - EXIT

# ---------------------------------------------------------------------------
# 6. Escape hatch, installed BEFORE the change that could need it.
# ---------------------------------------------------------------------------
if [ ! -f "$BACKUP" ]; then
    sudo install -m 0440 -o root -g root "$SUDOERS" "$BACKUP"
    info "backed up $SUDOERS -> $BACKUP"
fi

sudo install -m 0755 -o root -g root /dev/stdin /usr/local/bin/unharden-sudo <<'HATCH'
#!/bin/sh
# Emergency rollback: restore the pre-hardening sudoers (passwordless wheel).
# From a root shell:  su -    then  unharden-sudo
set -eu
[ "$(id -u)" -eq 0 ] || { echo "must be root; try 'su -' first" >&2; exit 1; }
[ -f /etc/sudoers.pre-harden.bak ] || { echo "no backup found" >&2; exit 1; }
visudo -cf /etc/sudoers.pre-harden.bak >/dev/null
install -m 0440 -o root -g root /etc/sudoers.pre-harden.bak /etc/sudoers
echo "restored passwordless sudoers. Re-harden with ~/scripts/harden-auth.sh"
HATCH
info "escape hatch at /usr/local/bin/unharden-sudo (reach it with 'su -')"

# ---------------------------------------------------------------------------
# 7. Rewrite /etc/sudoers.
#
#    Edited DIRECTLY rather than via a drop-in because on barry
#    `@includedir /etc/sudoers.d` was COMMENTED OUT - the directory was never
#    read, so /etc/sudoers.d/00_cjber was dead config and a drop-in would have
#    been silently ignored while NOPASSWD stayed live. The includedir is
#    restored below, but the %wheel rule here is authoritative either way.
#
#    timestamp_type is left at sudo's default (tty), not `global`. With
#    `global`, a process running as you in ANY terminal can reuse a timestamp
#    minted in another - exactly the "malicious dependency quietly becomes root"
#    path this closes. Add `Defaults timestamp_type=global` to trade it back.
# ---------------------------------------------------------------------------
new_sudoers=$(mktemp)
trap 'rm -f "$new_sudoers"' EXIT
cat >"$new_sudoers" <<EOF
$MARKER
# Authenticated sudo. Password OR phone push - see /etc/pam.d/sudo and
# ~/dotfiles/docs/phone-auth.md.

Defaults timestamp_timeout=15
Defaults passprompt="[sudo] password for %p (or press Enter for phone approval): "

root   ALL=(ALL:ALL) ALL
%wheel ALL=(ALL:ALL) ALL

@includedir /etc/sudoers.d
EOF

sudo visudo -cf "$new_sudoers" >/dev/null || die "generated sudoers failed validation; $SUDOERS untouched"
sudo install -m 0440 -o root -g root "$new_sudoers" "$SUDOERS"
info "sudoers now requires authentication (backup at $BACKUP)"

# Restoring @includedir makes /etc/sudoers.d live again. Surface what that
# activated rather than letting it apply silently.
if sudo test -d /etc/sudoers.d && [ -n "$(sudo ls -A /etc/sudoers.d 2>/dev/null)" ]; then
    warn "/etc/sudoers.d is read again (includedir had been commented out). Now-active drop-ins:"
    sudo ls -1 /etc/sudoers.d | sed 's/^/    /' >&2
fi

info "done. Test in a SECOND terminal, keeping this one open:"
info "    sudo -k && sudo true"
info "if sudo breaks:  su -   then   unharden-sudo"
