#!/bin/bash
# Scheduled worktree cleanup — a thin per-repo driver over the canonical prune
# script (~/.claude/skills/wt/prune.sh). One implementation for both the manual
# `/wt` prune and this daily systemd run, so they can never drift.
#
# For every repo in ~/.config/wt-cleanup/repos.conf it:
#   0. runs freshen.sh <repo> — puts the PRIMARY checkout back on main (only
#      when nothing would be lost) and fast-forwards it to origin/main, so the
#      main dir never drifts stale or sits on a feature branch (invariant 2).
#   1. runs prune.sh <repo>  — gh-authoritative removal of MERGED cb/ worktrees
#      (dir + local branch), open-PR/dirty/main guards, + `git worktree prune`
#      to drop orphaned admin refs.
#   2. sweeps truly-orphan directories under ~/.worktrees/<repo> that git no
#      longer tracks (leftover after an out-of-band `rm`), scoped strictly to
#      ~/.worktrees and WITHOUT sudo — it never touches a repo's main checkout.
# Finally it reaps long-untouched .venv dirs under ~/.worktrees (see below).
#
# This is the SINGLE worktree maintainer. It absorbed the former
# worktree-prune.{sh,service,timer}, which ran 13 minutes later over the same
# tree with weaker merge-detection (`git ls-remote` "branch gone" instead of
# gh-authoritative + open-PR guard). Two timers racing one tree meant whichever
# fired first decided the outcome, so a behaviour could never be attributed.
# The two things the old script did better are kept here: repo AUTO-DISCOVERY
# (below) and STALE VENV REAPING (bottom). Do not reintroduce a second timer.
#
# Driven by ~/.config/systemd/user/wt-cleanup.timer (daily).
set -euo pipefail
export PATH=/usr/bin:/usr/local/bin:/bin:${PATH:-}

PRUNE=/home/cjber/.claude/skills/wt/prune.sh
FRESHEN=/home/cjber/.claude/skills/wt/freshen.sh
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

# Auto-discover any repo that owns a worktree under ~/.worktrees but is absent
# from repos.conf. Inherited from the retired worktree-prune.sh, and the reason
# it was worth keeping: a hand-maintained list silently omits repos, and an
# omitted repo gets neither a main refresh nor a prune — its main just rots.
# Discovery is by asking each worktree for its own primary checkout, so it
# cannot invent a path. Explicit repos.conf entries win (their <name> may
# legitimately differ from the directory basename).
# Worktrees sit at ~/.worktrees/<name> and ~/.worktrees/<repo>/<name>, so the
# .git marker of both is within -maxdepth 3.
while IFS= read -r gitmarker; do
    wt="$(dirname "$gitmarker")"
    primary="$(git -C "$wt" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || continue
    primary="${primary%/.git}"
    [[ -n "$primary" && -d "$primary" ]] || continue
    [[ "$primary" == "$wt" ]] && continue          # this IS a primary, not a worktree
    [[ -v REPOS[$primary] ]] && continue           # explicit config wins
    REPOS[$primary]="$(basename "$primary")"
    log "discovered repo not in repos.conf: $primary"
done < <(find "$WORKTREES_ROOT" -maxdepth 3 -name .git -print 2>/dev/null || true)

for repo in "${!REPOS[@]}"; do
    name="${REPOS[$repo]}"
    # Guard: only operate on a real repo whose main dir is present.
    [[ -d "$repo/.git" || -f "$repo/.git" ]] || { log "skip $repo (not a repo)"; continue; }

    # 0. Keep the primary checkout on main and fast-forwarded. Runs FIRST so the
    #    prune below sees an up-to-date origin/main when deciding what merged.
    if [[ -f "$FRESHEN" ]]; then
        bash "$FRESHEN" "$repo" || log "  freshen.sh failed for $name"
    else
        log "  freshen.sh not found at $FRESHEN — skipping main refresh for $name"
    fi

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

# 3. Reap virtualenvs in worktrees nobody has touched in STALE_VENV_DAYS.
#
# This is why the retired worktree-prune.sh existed at all: ~80 worktree .venvs
# (318 packages of tiny files each) exhausted btrfs METADATA at 48.5/49.0 GiB,
# so every write failed ENOSPC while `df` still showed 74 GiB free. Recovery
# meant deleting files FIRST, then `btrfs balance` — which itself needs
# metadata headroom. Losing this step re-arms that failure, so it moved here
# rather than being dropped with the timer.
#
# Only the .venv goes; the worktree, its branch and any uncommitted work are
# untouched, and `uv sync` rebuilds one in seconds.
STALE_VENV_DAYS="${STALE_VENV_DAYS:-30}"
venvs=0
if [[ -d "$WORKTREES_ROOT" && "$STALE_VENV_DAYS" -gt 0 ]]; then
    while IFS= read -r venv; do
        rm -rf -- "$venv" && { log "dropped stale venv ($STALE_VENV_DAYS+ days): $venv"; venvs=$((venvs + 1)); }
    done < <(find "$WORKTREES_ROOT" -maxdepth 4 -name .venv -type d -mtime "+$STALE_VENV_DAYS" 2>/dev/null || true)
fi

log "done. repos=${#REPOS[@]} stale_venvs_dropped=$venvs"
