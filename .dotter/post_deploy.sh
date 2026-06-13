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
