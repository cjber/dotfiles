#!/usr/bin/env bash
# Run on a fresh Arch install on the NUC as user `cjber`.
# Assumes ~/.dotfiles has already been cloned. Idempotent — safe to re-run.

set -euo pipefail

log()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
have() { command -v "$1" &>/dev/null; }

[[ -d "$HOME/.dotfiles" ]] || {
  echo "Clone the dotfiles repo to ~/.dotfiles first." >&2
  exit 1
}

log "Updating system"
sudo pacman -Syu --noconfirm

log "Installing foundation packages"
sudo pacman -S --needed --noconfirm \
  base-devel git openssh zsh \
  tailscale mosh \
  rsync rclone restic \
  zellij neovim kitty-terminfo \
  unzip jq ripgrep fd starship direnv zoxide fzf yazi \
  github-cli nodejs npm python python-pip \
  zsh-antidote

log "Masking sleep targets (server stays awake)"
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

log "Enabling sshd + tailscaled (tailscale up is a separate manual step)"
sudo systemctl enable --now sshd tailscaled

if ! have paru; then
  log "Installing paru (AUR helper)"
  tmp=$(mktemp -d)
  git -C "$tmp" clone https://aur.archlinux.org/paru.git
  ( cd "$tmp/paru" && makepkg -si --noconfirm )
  rm -rf "$tmp"
fi

if ! have dotter; then
  log "Installing dotter"
  paru -S --needed --noconfirm dotter-rs-bin
fi

if [[ ! -f "$HOME/.dotfiles/.dotter/local.toml" ]]; then
  log "Selecting 'headless' dotter package"
  printf 'packages = ["headless"]\n' > "$HOME/.dotfiles/.dotter/local.toml"
fi

log "Deploying dotfiles"
( cd "$HOME/.dotfiles" && dotter deploy --force )

if [[ "$SHELL" != */zsh ]]; then
  log "Changing login shell to zsh (you may need to log out + back in)"
  sudo chsh -s /usr/bin/zsh "$USER"
fi

if ! have uv; then
  log "Installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

if ! have pnpm; then
  log "Installing pnpm via corepack"
  sudo corepack enable
  corepack prepare pnpm@latest --activate
fi

log "Enabling user lingering so systemd --user timers run without login"
sudo loginctl enable-linger "$USER"

mkdir -p "$HOME/.config/restic" "$HOME/drive/agl"

cat <<'EOF'

==> Bootstrap done. Manual next steps (need browser / interactive auth):

  1. Tailscale, personal tailnet:
       sudo tailscale up --ssh --hostname=nuc --operator=cjber
     Open the URL it prints. Double-check the tailnet name on Tailscale's
     auth page matches your PERSONAL account before approving.

  2. Authorised SSH key from the desktop:
       ssh-copy-id cjber@<nuc-ip>      # run on desktop, before next step
     Then on the NUC:
       sudo tee /etc/ssh/sshd_config.d/99-local.conf <<<'PasswordAuthentication no'
       sudo systemctl reload sshd

  3. GitHub auth:
       gh auth login

  4. rclone Google Drive (fresh OAuth, don't reuse desktop rclone.conf):
       rclone config           # add remote named 'gdrive'

  5. Restic repo on the NAS:
       echo '<strong-password>' > ~/.config/restic/password
       chmod 600 ~/.config/restic/password
       restic -r sftp:nas:/share/restic/nuc init

  6. Claude Code:
       (install per current method)
       claude login

  7. Clone all nebula-* repos:
       cd ~/drive/agl
       for r in nebula-web nebula-mobile nebula-desktop nebula-metabase \
                nebula-cli nebula-docs nebula-live; do
         gh repo clone <org>/$r
       done
     Then per-repo: `pnpm install` (Node) or `uv sync` (Python).

  8. scp .env files from the desktop for each nebula-* repo.

EOF
