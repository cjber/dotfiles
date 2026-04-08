#!/bin/bash
# Clean up worktree clutter:
#  1. Orphan dirs left after `git worktree prune`
#  2. Active worktrees whose branch was already merged on the remote (via gh)
# Driven by ~/.config/systemd/user/wt-cleanup.timer (daily).

set -euo pipefail

# Map: <parent-repo-checkout-path> => <worktree-dir-name-on-disk>
declare -A REPOS=(
    [/home/cjber/drive/thirdweb/projects/nebula]=nebula
    [/home/cjber/drive/thirdweb/projects/nebula-web]=nebula-web
)

WORKTREES_ROOT="$HOME/.worktrees"
PROTECTED_BRANCHES_RE='^(main|master|develop|HEAD)$'

log() { printf '[wt-cleanup] %s\n' "$*"; }
hr_size() { numfmt --to=iec --suffix=B "$1" 2>/dev/null || echo "$1 B"; }

reclaimed_total=0
have_gh=0
command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 && have_gh=1

remove_path() {
    local target=$1 sz
    sz=$(du -sb "$target" 2>/dev/null | cut -f1 || echo 0)
    if rm -rf "$target" 2>/dev/null || sudo rm -rf "$target" 2>/dev/null; then
        reclaimed_total=$((reclaimed_total + sz))
        return 0
    fi
    log "  failed to remove $target"
    return 1
}

for repo in "${!REPOS[@]}"; do
    name="${REPOS[$repo]}"
    wt_dir="$WORKTREES_ROOT/$name"

    [[ -d "$repo/.git" || -f "$repo/.git" ]] || { log "skip $repo (not a repo)"; continue; }
    [[ -d "$wt_dir" ]] || { log "skip $name (no $wt_dir)"; continue; }

    git -C "$repo" worktree prune

    # ----- Step 1: orphan dirs not tracked by git -----
    mapfile -t active_paths < <(git -C "$repo" worktree list --porcelain | awk '/^worktree/ {print $2}')
    declare -A active_set=()
    for p in "${active_paths[@]}"; do active_set[$(basename "$p")]=1; done

    orphans_removed=0
    for entry in "$wt_dir"/*; do
        [[ -d "$entry" ]] || continue
        base=$(basename "$entry")
        if [[ -z "${active_set[$base]:-}" ]]; then
            remove_path "$entry" && orphans_removed=$((orphans_removed + 1))
        fi
    done
    unset active_set

    # ----- Step 2: active worktrees whose PR is merged -----
    merged_removed=0 merged_skipped_dirty=0
    if (( have_gh )); then
        for wt_path in "${active_paths[@]}"; do
            # Skip the main checkout itself.
            [[ "$wt_path" == "$repo" ]] && continue
            [[ -d "$wt_path" ]] || continue

            branch=$(git -C "$wt_path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
            [[ -z "$branch" || "$branch" == "HEAD" ]] && continue
            [[ "$branch" =~ $PROTECTED_BRANCHES_RE ]] && continue

            # Skip if dirty (uncommitted/untracked changes)
            if [[ -n "$(git -C "$wt_path" status --porcelain 2>/dev/null)" ]]; then
                continue
            fi

            # Was this branch's PR merged on the remote?
            merged_count=$(cd "$wt_path" && gh pr list --head "$branch" --state merged --json number --limit 1 2>/dev/null | grep -c '"number"' || true)
            if (( merged_count > 0 )); then
                log "  $name: $branch merged → removing $wt_path"
                sz=$(du -sb "$wt_path" 2>/dev/null | cut -f1 || echo 0)
                if git -C "$repo" worktree remove "$wt_path" 2>/dev/null; then
                    reclaimed_total=$((reclaimed_total + sz))
                    merged_removed=$((merged_removed + 1))
                else
                    # worktree may have stash/locks; force remove dir
                    remove_path "$wt_path" && merged_removed=$((merged_removed + 1))
                fi
            fi
        done
    fi

    log "$name: removed $orphans_removed orphan(s), $merged_removed merged worktree(s)"
done

log "done. reclaimed: $(hr_size "$reclaimed_total")"
