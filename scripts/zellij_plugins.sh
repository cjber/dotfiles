#!/usr/bin/env bash
# Idempotent download of pinned zellij WASM plugins. Run after dotter deploy.

set -euo pipefail

ZJSTATUS_VERSION="v0.23.0"
PLUGIN_DIR="$HOME/.config/zellij/plugins"
mkdir -p "$PLUGIN_DIR"

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
