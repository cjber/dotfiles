#!/usr/bin/env sh
# dotter post-deploy hook: bootstrap paru clean-chroot builds.
#
# Runs after every `dotter deploy`. It is OPT-IN (only acts when the deployed
# paru.conf requests Chroot + LocalRepo) and IDEMPOTENT (a no-op once set up,
# with no sudo prompt on already-configured machines). On a fresh machine it
# prompts for sudo once to wire up the local repo, pacman.conf and sudoers.
#
# Rationale for each step lives in the AUR-malware-protection notes; the key
# non-obvious one is the sudoers rule: makechrootpkg runs `sudo -u $USER` while
# it is itself root, so root must be authorised in /etc/sudoers.
set -u

# Dotter expands source directories, including directory symlinks, into links
# for each contained file. Codex discovers symlinked skill directories but can
# omit a real directory containing a symlinked SKILL.md, so install portable
# skills as whole-directory links after Dotter has reconciled its file cache.
DOTFILES_DIR=$(pwd -P)
link_skill_directory() {
    skill_source=$1
    skill_target=$2
    mkdir -p "$(dirname -- "$skill_target")"

    if [ -L "$skill_target" ] || [ ! -e "$skill_target" ]; then
        ln -sfn "$skill_source" "$skill_target"
    else
        echo "[dotter] warning: $skill_target exists and is not a symlink; leaving it alone" >&2
    fi
}

link_skill_directory "$DOTFILES_DIR/claude/skills/dev" "$HOME/.agents/skills/dev"
link_skill_directory "$DOTFILES_DIR/claude/skills/pr" "$HOME/.agents/skills/pr"
link_skill_directory "$DOTFILES_DIR/claude/skills/dev" "$HOME/.codex/skills/dev"
link_skill_directory "$DOTFILES_DIR/codex/skills/pr" "$HOME/.codex/skills/pr"

# Keep the Hyprland Lua helper module available without letting Dotter expand
# and manage the external ~/src/hyprview git checkout.
HYPRVIEW_SRC="$HOME/src/hyprview"
HYPRVIEW_TARGET="$HOME/.config/hypr/hyprview"
if [ -d "$HYPRVIEW_SRC" ]; then
    if [ -L "$HYPRVIEW_TARGET" ] || [ ! -e "$HYPRVIEW_TARGET" ]; then
        ln -sfn "$HYPRVIEW_SRC" "$HYPRVIEW_TARGET"
    else
        echo "[dotter] warning: $HYPRVIEW_TARGET exists and is not a symlink; leaving it alone" >&2
    fi
fi

# --- RTL8125 dual-boot NIC reset (system service + rescue helper) ---------
# Installs the shutdown-time NIC reset so a warm reboot hands Windows a clean
# chip (the RTL8125 strands its link across OS handoffs otherwise). The
# `fix-nic` rescue command is deployed by dotter to ~/scripts. Idempotent:
# no-op (and no sudo prompt) once installed; only runs on a host with eno1.
NIC_SRC="$HOME/.dotfiles/system"
if [ -e /sys/class/net/eno1 ] && [ -d "$NIC_SRC" ]; then
    nic_changed=0
    if ! cmp -s "$NIC_SRC/reset-r8125-shutdown.sh" /usr/local/bin/reset-r8125-shutdown.sh 2>/dev/null; then
        sudo install -m 755 "$NIC_SRC/reset-r8125-shutdown.sh" /usr/local/bin/reset-r8125-shutdown.sh
        nic_changed=1
    fi
    if ! cmp -s "$NIC_SRC/reset-r8125.service" /etc/systemd/system/reset-r8125.service 2>/dev/null; then
        sudo install -m 644 "$NIC_SRC/reset-r8125.service" /etc/systemd/system/reset-r8125.service
        nic_changed=1
    fi
    [ "$nic_changed" = 1 ] && { sudo systemctl daemon-reload; echo "[dotter] installed RTL8125 reset service"; }
    systemctl is-enabled reset-r8125.service >/dev/null 2>&1 || sudo systemctl enable reset-r8125.service
fi
# --- end NIC -------------------------------------------------------------

PARU_CONF="$HOME/.config/paru/paru.conf"
REPO_DIR="/var/cache/aur_local"
REPO_NAME="aur_local"

# Opt-in: do nothing unless the deployed paru.conf asks for chroot + local repo.
grep -q '^Chroot'    "$PARU_CONF" 2>/dev/null || exit 0
grep -q '^LocalRepo' "$PARU_CONF" 2>/dev/null || exit 0

# Fast, sudo-free short-circuit when already bootstrapped.
if [ -d "$REPO_DIR" ] && grep -q "^\[$REPO_NAME\]" /etc/pacman.conf 2>/dev/null; then
    exit 0
fi

echo "[dotter] bootstrapping paru clean-chroot builds (sudo required once)..."
command -v makechrootpkg >/dev/null 2>&1 || \
    echo "[dotter] WARNING: install 'devtools' for chroot builds to work"

# 1. Local repo on a world-traversable path (pacman DownloadUser can't read \$HOME).
if [ ! -d "$REPO_DIR" ]; then
    sudo install -d -o "$USER" -g "$USER" "$REPO_DIR"
    repo-add "$REPO_DIR/$REPO_NAME.db.tar.zst" >/dev/null 2>&1 || true
    echo "[dotter] created local repo at $REPO_DIR"
fi

# 2. Declare the repo in pacman.conf (lowest priority, official repos win).
if ! grep -q "^\[$REPO_NAME\]" /etc/pacman.conf; then
    printf '\n[%s]\nSigLevel = Optional TrustAll\nServer = file://%s\n' \
        "$REPO_NAME" "$REPO_DIR" | sudo tee -a /etc/pacman.conf >/dev/null
    echo "[dotter] added [$REPO_NAME] to /etc/pacman.conf"
fi

# 3. Ensure root is authorised in sudoers (needed by makechrootpkg).
if ! sudo grep -qE '^root[[:space:]]+ALL=\(ALL:ALL\) ALL' /etc/sudoers; then
    printf 'root ALL=(ALL:ALL) ALL\n' | sudo tee -a /etc/sudoers >/dev/null
    sudo visudo -c >/dev/null && echo "[dotter] added root rule to /etc/sudoers"
fi

sudo pacman -Sy >/dev/null 2>&1 || true
echo "[dotter] clean-chroot build setup complete."
