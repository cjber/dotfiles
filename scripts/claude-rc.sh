#!/usr/bin/env bash
# Runs `claude remote-control` as a persistent server for one repo.
# Invoked by claude-rc@<instance>.service; $1 is a repo dir under ~/drive/agl,
# or the literal "agl" for the machine-wide catch-all rooted at that parent dir.
#
# Remote Control needs claude.ai subscription auth, so ANTHROPIC_API_KEY must
# not be set (it would force API-key auth and the command refuses to start).
set -euo pipefail

instance="${1:?usage: claude-rc.sh <repo-name|agl>}"

# Claude's Remote Control server is bound to ONE directory - unlike Codex's
# app-server daemon, which is machine-wide and picks a cwd per session. Cross-
# repo coverage therefore means one unit per repo, plus this catch-all rooted at
# the parent so a directory with no unit of its own is still reachable by phone.
if [ "$instance" = "agl" ]; then
    dir="$HOME/drive/agl"
    name="barry"
else
    dir="$HOME/drive/agl/$instance"
    name="$instance"
fi

[ -d "$dir" ] || { echo "claude-rc: $dir does not exist" >&2; exit 1; }

# Worktree spawn mode requires a git repo; the catch-all parent is not one, so
# it serves same-dir sessions instead of failing to start.
if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
    spawn=worktree
else
    spawn=same-dir
fi

unset ANTHROPIC_API_KEY ANTHROPIC_AUTH_TOKEN
export PATH="$HOME/.local/bin:$PATH"

cd "$dir"
# bypassPermissions deliberately: these servers are driven from a phone, where
# an approval prompt stalls the run until it is noticed. Matches the Codex side
# (approval_policy = "never", sandbox_mode = "danger-full-access").
exec claude remote-control \
    --spawn="$spawn" \
    --permission-mode bypassPermissions \
    --name "$name"
