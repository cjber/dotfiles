#!/usr/bin/env bash
# Enforce authenticated sudo, and optionally wire up Duo phone-push approval.
#
# Why this is a script and not dotter-managed files:
#   - /etc/sudoers and its drop-ins must be mode 0440 and root-owned or sudo
#     refuses to read them ("unsafe mode"). Dotter deploys 0644 and has no
#     per-file permission setting.
#   - /etc/duo/pam_duo.conf holds a Duo SECRET KEY. cjber/dotfiles is a PUBLIC
#     repo and .dotter/local-root.toml is tracked, so the secret can live in
#     neither the repo nor a dotter variable. It is written here, at 0600, from
#     an argument or a prompt, and never persisted to the repo.
#
# The PAM stack itself (/etc/pam.d/sudo) IS dotter-managed - it is 0644 and
# holds no secrets. See docs/phone-auth.md.
#
# Idempotent: safe to re-run. Re-running without Duo credentials leaves an
# existing Duo config untouched.
#
# Usage:
#   ~/scripts/harden-auth.sh                      # sudo hardening only
#   ~/scripts/harden-auth.sh --duo IKEY SKEY HOST # also configure phone push
#   ~/scripts/harden-auth.sh --skip-password-check # for automation only
set -euo pipefail

SUDOERS=/etc/sudoers
BACKUP=/etc/sudoers.pre-harden.bak
MARKER='# managed by ~/scripts/harden-auth.sh'
SKIP_PW_CHECK=0
DUO_IKEY=""
DUO_SKEY=""
DUO_HOST=""

die() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33mwarning:\033[0m %s\n' "$*" >&2; }

while [ $# -gt 0 ]; do
    case $1 in
        --duo)
            [ $# -ge 4 ] || die "--duo needs three values: IKEY SKEY API_HOST"
            DUO_IKEY=$2; DUO_SKEY=$3; DUO_HOST=$4; shift 4 ;;
        --skip-password-check) SKIP_PW_CHECK=1; shift ;;
        -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[ "$(id -u)" -ne 0 ] || die "run as your normal user, not root (it needs to know who you are)"

# ---------------------------------------------------------------------------
# 1. Refuse to proceed if this user has no usable password. Removing NOPASSWD
#    with a locked or empty password hash is a guaranteed lockout: sudo would
#    become unusable and there would be no way back short of a rescue USB.
# ---------------------------------------------------------------------------
hash=$(sudo getent shadow "$USER" | cut -d: -f2)
case "$hash" in
    ''|'!'*|'*'|'!!')
        die "$USER has no usable password hash ('${hash:-empty}'). Set one with 'passwd' first, or removing NOPASSWD will lock you out of sudo entirely." ;;
esac
info "password hash present for $USER ($(printf '%s' "$hash" | cut -c1-3)...)"

# ---------------------------------------------------------------------------
# 2. Prove the user actually KNOWS that password before taking away NOPASSWD.
#    A valid hash in shadow is not the same as a remembered password. `su` to
#    yourself is a non-destructive way to force a real authentication.
# ---------------------------------------------------------------------------
if [ "$SKIP_PW_CHECK" -eq 0 ]; then
    info "verifying you know your password - enter it at the prompt below"
    su "$USER" -c true || die "password verification failed. Nothing has been changed. Fix your password with 'passwd' (you still have NOPASSWD sudo right now) and re-run."
    info "password verified"
fi

# ---------------------------------------------------------------------------
# 3. Escape hatch, installed BEFORE the change that could need it.
# ---------------------------------------------------------------------------
if [ ! -f "$BACKUP" ]; then
    sudo install -m 0440 -o root -g root "$SUDOERS" "$BACKUP"
    info "backed up $SUDOERS -> $BACKUP"
fi

sudo install -m 0755 -o root -g root /dev/stdin /usr/local/bin/unharden-sudo <<'HATCH'
#!/bin/sh
# Emergency rollback: restore the pre-hardening sudoers (passwordless wheel).
# Run from a root shell:  su -    then  unharden-sudo
set -eu
[ "$(id -u)" -eq 0 ] || { echo "must be root; try 'su -' first" >&2; exit 1; }
[ -f /etc/sudoers.pre-harden.bak ] || { echo "no backup found" >&2; exit 1; }
visudo -cf /etc/sudoers.pre-harden.bak >/dev/null
install -m 0440 -o root -g root /etc/sudoers.pre-harden.bak /etc/sudoers
echo "restored passwordless sudoers. Re-harden with ~/scripts/harden-auth.sh"
HATCH
info "escape hatch installed at /usr/local/bin/unharden-sudo (run as root via 'su -')"

# ---------------------------------------------------------------------------
# 4. Rewrite /etc/sudoers.
#
#    This edits /etc/sudoers DIRECTLY rather than shipping a drop-in, because
#    on this machine `@includedir /etc/sudoers.d` was COMMENTED OUT - so
#    /etc/sudoers.d was never read at all and /etc/sudoers.d/00_cjber was dead
#    config. A drop-in would have been silently ignored while NOPASSWD stayed
#    live. The includedir is restored below, but correctness does not depend on
#    it: the %wheel rule here is authoritative either way.
#
#    timestamp_type is left at sudo's default (tty) rather than `global`. With
#    `global`, any process running as this user in ANY terminal can reuse a
#    sudo timestamp minted in another one - which is precisely the "malicious
#    dependency silently becomes root" path this hardening exists to close.
#    `tty` scopes the cache to the terminal that authenticated. To trade that
#    back for convenience, add: Defaults timestamp_type=global
# ---------------------------------------------------------------------------
new_sudoers=$(mktemp)
trap 'rm -f "$new_sudoers"' EXIT
cat >"$new_sudoers" <<EOF
$MARKER
# Authenticated sudo. Password OR phone push - see /etc/pam.d/sudo.

Defaults timestamp_timeout=15
Defaults passprompt="[sudo] password for %p (or press Enter for phone approval): "

root  ALL=(ALL:ALL) ALL
%wheel ALL=(ALL:ALL) ALL

@includedir /etc/sudoers.d
EOF

sudo visudo -cf "$new_sudoers" >/dev/null || die "generated sudoers failed validation; $SUDOERS untouched"
sudo install -m 0440 -o root -g root "$new_sudoers" "$SUDOERS"
info "sudoers now requires authentication (backup at $BACKUP)"

# Restoring @includedir makes /etc/sudoers.d live again. Anything already in
# there takes effect now, so surface it rather than letting it apply silently.
if sudo test -d /etc/sudoers.d && [ -n "$(sudo ls -A /etc/sudoers.d 2>/dev/null)" ]; then
    warn "/etc/sudoers.d is now read again (includedir was commented out before). Active drop-ins:"
    sudo ls -1 /etc/sudoers.d | sed 's/^/    /' >&2
fi

# ---------------------------------------------------------------------------
# 5. Duo phone push (optional).
# ---------------------------------------------------------------------------
if [ -n "$DUO_IKEY" ]; then
    command -v /usr/bin/login_duo >/dev/null 2>&1 || warn "duo_unix not installed (paru -S duo_unix)"
    [ -f /usr/lib/security/pam_duo.so ] || die "pam_duo.so missing; install duo_unix first"

    sudo install -d -m 0755 -o root -g root /etc/duo
    sudo install -m 0600 -o root -g root /dev/stdin /etc/duo/pam_duo.conf <<EOF
[duo]
ikey = $DUO_IKEY
skey = $DUO_SKEY
host = $DUO_HOST

; Deny when Duo is unreachable. Duo's default (safe) ALLOWS access on failure,
; which would silently restore passwordless sudo whenever the network is down.
; The password path in /etc/pam.d/sudo is the intended fallback, not fail-open.
failmode = secure

; Send the push immediately instead of showing a factor menu.
autopush = yes
prompts = 1

; Do not send the client IP; a workstation behind NAT gives Duo nothing useful.
send_gecos = no
EOF
    info "wrote /etc/duo/pam_duo.conf (0600 root) with failmode=secure"
elif sudo test -s /etc/duo/pam_duo.conf && sudo grep -q '^ikey = D' /etc/duo/pam_duo.conf 2>/dev/null; then
    info "existing Duo config left untouched"
else
    warn "Duo is NOT configured, so the phone path is inert - pam_duo will fail and sudo will accept your password only. That is a safe state, not a broken one. Configure it with:"
    warn "    ~/scripts/harden-auth.sh --duo <IKEY> <SKEY> <API_HOST>"
fi

# ---------------------------------------------------------------------------
# 6. Verify the PAM stack is the dotter-managed one.
# ---------------------------------------------------------------------------
if ! grep -q 'pam_duo.so' /etc/pam.d/sudo 2>/dev/null; then
    warn "/etc/pam.d/sudo has no pam_duo line - run the root dotter deploy:"
    warn "    cd ~/dotfiles && sudo dotter -l .dotter/local-root.toml \\"
    warn "      --cache-file .dotter/cache-root.toml --cache-directory .dotter/cache-root deploy --force"
fi

info "done. Test in a SECOND terminal (keep this one open): sudo -k && sudo true"
info "if sudo breaks: su -   then   unharden-sudo"
