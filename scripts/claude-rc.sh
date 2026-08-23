#!/usr/bin/env bash
# Runs `claude remote-control` as a persistent server for one repo.
# Invoked by claude-rc@<repo>.service; $1 is the repo dir under ~/drive/agl.
#
# Remote Control needs claude.ai subscription auth, so ANTHROPIC_API_KEY must
# not be set (it would force API-key auth and the command refuses to start).
set -euo pipefail

repo="${1:?usage: claude-rc.sh <repo-name>}"
dir="$HOME/drive/agl/$repo"

[ -d "$dir/.git" ] || { echo "claude-rc: $dir is not a git repo" >&2; exit 1; }

unset ANTHROPIC_API_KEY ANTHROPIC_AUTH_TOKEN
export PATH="$HOME/.local/bin:$PATH"

cd "$dir"
exec claude remote-control --spawn=worktree --name "$repo"
