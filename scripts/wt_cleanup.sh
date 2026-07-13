#!/bin/bash
# Scheduled worktree cleanup — a thin per-repo driver over the canonical prune
# script (~/.claude/skills/wt/prune.sh). One implementation for both the manual
# `/wt` prune and this daily systemd run, so they can never drift.
#
# For every repo in ~/.config/wt-cleanup/repos.conf it:
#   1. runs prune.sh <repo>  — gh-authoritative removal of MERGED cb/ worktrees
#      (dir + local branch), open-PR/dirty/main guards, + `git worktree prune`
#      to drop orphaned admin refs.
#   2. sweeps truly-orphan directories under ~/.worktrees/<repo> that git no
#      longer tracks (leftover after an out-of-band `rm`), scoped strictly to
#      ~/.worktrees and WITHOUT sudo — it never touches a repo's main checkout.
#
# Driven by ~/.config/systemd/user/wt-cleanup.timer (daily).
set -euo pipefail
export PATH=/usr/bin:/usr/local/bin:/bin:${PATH:-}

PRUNE=/home/cjber/.claude/skills/wt/prune.sh
WORKTREES_ROOT="$HOME/.worktrees"

# Repo map from a local, gitignored config that populates REPOS, e.g.:
#   REPOS[/home/cjber/drive/agl/nebula]=nebula
declare -A REPOS=()
CONF="${XDG_CONFIG_HOME:-$HOME/.config}/wt-cleanup/repos.conf"
if [[ -f "$CONF" ]]; then
    # shellcheck disable=SC1090
    source "$CONF"
else
    echo "[wt-cleanup] no $CONF — nothing to do." >&2
    exit 0
fi

log() { printf '[wt-cleanup] %s\n' "$*"; }

for repo in "${!REPOS[@]}"; do
    name="${REPOS[$repo]}"
    # Guard: only operate on a real repo whose main dir is present.
    [[ -d "$repo/.git" || -f "$repo/.git" ]] || { log "skip $repo (not a repo)"; continue; }

    # 1. Canonical prune: merged cb/ worktrees + branches + orphaned admin refs.
    if [[ -x "$PRUNE" || -f "$PRUNE" ]]; then
        log "$name: prune.sh"
        bash "$PRUNE" "$repo" || log "  prune.sh failed for $name"
    else
        log "  prune.sh not found at $PRUNE — skipping merged-prune for $name"
    fi

    # 2. Orphan-dir sweep, scoped strictly to ~/.worktrees/<name>. A dir here
    #    that git no longer lists is leftover clutter from a manual removal.
    wt_dir="$WORKTREES_ROOT/$name"
    [[ -d "$wt_dir" ]] || continue
    mapfile -t active < <(git -C "$repo" worktree list --porcelain | awk '/^worktree/ {print $2}')
    declare -A active_set=()
    for p in "${active[@]}"; do active_set["$p"]=1; done
    for entry in "$wt_dir"/*; do
        [[ -d "$entry" ]] || continue
        # Only remove if git does NOT track this path as a worktree. No sudo.
        if [[ -z "${active_set[$entry]:-}" ]]; then
            log "  $name: removing orphan dir $entry"
            rm -rf -- "$entry" || log "    failed to remove $entry"
        fi
    done
    unset active_set
done

log "done."
