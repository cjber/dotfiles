#!/usr/bin/env bash
# Idempotent download of pinned zellij WASM plugins + permission grant.
# Run after dotter deploy.

set -euo pipefail

ZJSTATUS_VERSION="v0.23.0"
PLUGIN_DIR="$HOME/.config/zellij/plugins"
CACHE_DIR="$HOME/.cache/zellij"
mkdir -p "$PLUGIN_DIR" "$CACHE_DIR"

fetch() {
  local url="$1" dest="$2"
  if [[ -s "$dest" ]]; then
    echo "ok      $(basename "$dest")"
    return
  fi
  echo "fetch   $(basename "$dest")"
  curl -sSL --fail -o "$dest.tmp" "$url"
  mv "$dest.tmp" "$dest"
}

fetch \
  "https://github.com/dj95/zjstatus/releases/download/${ZJSTATUS_VERSION}/zjstatus.wasm" \
  "$PLUGIN_DIR/zjstatus.wasm"

# Pre-grant permissions so zjstatus can read session/tab/mode state without
# the on-first-run interactive prompt (which is invisible in a size=1 bar pane).
PERM_FILE="$CACHE_DIR/permissions.kdl"
if ! grep -q 'ReadApplicationState' "$PERM_FILE" 2>/dev/null; then
  echo "grant   permissions.kdl"
  cat > "$PERM_FILE" <<EOF
"$PLUGIN_DIR/zjstatus.wasm" {
    ReadApplicationState
    ChangeApplicationState
    RunCommands
    OpenFiles
    Reconfigure
}
EOF
else
  echo "ok      permissions.kdl"
fi
