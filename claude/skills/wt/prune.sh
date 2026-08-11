#!/usr/bin/env bash
# Prune merged cb/ worktrees (worktree dir + local branch) using plain git.
# gwq is NOT used for removal: it re-invokes `git` from PATH and dies silently
# in non-TTY / PATH-stripped shells (Claude Code Bash pipelines) - the reason
# the old inline prune loop "always broke".
#
# Merged-detection is GitHub-authoritative: ONE `gh pr list --state merged`
# call builds the merged-head set; a branch is removable iff its name is in
# that set, or it is a literal fast-forward ancestor of origin/main (no-PR
# local branch). Branches with an OPEN PR are always kept, even if a
# same-named merged PR exists. No tree-equivalence heuristics.
set -u
export PATH=/usr/bin:/usr/local/bin:/bin:${PATH:-}

cd "${1:-$PWD}" || exit 1

# Guard 1: primary checkout only, never a worktree.
if git rev-parse --git-common-dir 2>/dev/null | grep -q '/worktrees/'; then
    echo "refusing to prune: run from the primary checkout, not a worktree" >&2
    exit 1
fi

git fetch --quiet --prune origin
MAIN_TOPLEVEL="$(git rev-parse --show-toplevel)"

# ONE API call each (per-branch gh calls get secondary-rate-limited to empty).
MERGED_HEADS="$(gh pr list --state merged --limit 1000 --json headRefName -q '.[].headRefName')" || exit 1
OPEN_HEADS="$(gh pr list --state open --limit 200 --json headRefName -q '.[].headRefName')" || exit 1

is_merged() {
    if printf '%s\n' "$MERGED_HEADS" | grep -qxF "$1"; then
        return 0
    fi
    local tip mb
    tip=$(git rev-parse "$1" 2>/dev/null) || return 1
    mb=$(git merge-base origin/main "$1" 2>/dev/null) || return 1
    [ "$mb" = "$tip" ]
}

# Branches a worktree is holding, INCLUDING one held only by an interrupted
# rebase. Such a worktree is detached, so `git worktree list` prints no `branch`
# line for it and both passes below would otherwise miss the branch entirely -
# the second pass then tries `git branch -D`, git refuses ("used by worktree"),
# and every run leaks a raw error while the real signal (unfinished work parked
# mid-rebase) is never surfaced. Treat these as in-use and say so.
in_use_branches() {
    git worktree list --porcelain | awk '/^worktree /{print $2}' | while read -r p; do
        [ -d "$p" ] || continue
        gd=$(git -C "$p" rev-parse --absolute-git-dir 2>/dev/null) || continue
        git -C "$p" symbolic-ref --quiet --short HEAD 2>/dev/null
        for f in "$gd/rebase-merge/head-name" "$gd/rebase-apply/head-name"; do
            [ -f "$f" ] && sed 's|^refs/heads/||' "$f"
        done
    done
}
IN_USE="$(in_use_branches)"

removed=0 kept=0
LIST="$(mktemp)"
# Collect first, act after - no side effects inside a pipeline subshell.
git worktree list --porcelain | awk '/^worktree /{p=$2} /^branch /{print p, $2}' > "$LIST"

# Surface detached worktrees rather than silently skipping them: a detached tree
# is usually an interrupted rebase/bisect, i.e. work someone still needs.
git worktree list --porcelain | awk '
    /^worktree /{p=$2; d=0} /^detached/{d=1} /^$/{if(d && p!="") print p; p=""}
    END{if(d && p!="") print p}' | while read -r p; do
    [ "$p" = "$MAIN_TOPLEVEL" ] && continue
    echo "keep (detached — likely an interrupted rebase): $p"
done

while read -r path ref; do
    branch=${ref#refs/heads/}
    [ "$path" = "$MAIN_TOPLEVEL" ] && continue                  # Guard 2: skip main checkout
    case "$branch" in cb/*) ;; *) continue ;; esac              # only cb/ feature branches
    { [ "$branch" = main ] || [ "$branch" = master ]; } && continue  # Guard 3: never the default branch
    [ -d "$path" ] || continue                                  # missing dir -> git worktree prune below
    if [ -n "$(git -C "$path" status --porcelain 2>/dev/null)" ]; then
        echo "keep (dirty): $branch"
        kept=$((kept + 1))
        continue
    fi
    if printf '%s\n' "$OPEN_HEADS" | grep -qxF "$branch"; then
        echo "keep (open PR): $branch"
        kept=$((kept + 1))
        continue
    fi
    if is_merged "$branch"; then
        if git worktree remove "$path" && git branch -D "$branch"; then
            echo "removed: $branch ($path)"
            removed=$((removed + 1))
        else
            echo "FAILED to remove: $branch ($path)" >&2
        fi
    fi
done < "$LIST"
rm -f "$LIST"

# Second pass: merged cb/ local branches with no worktree at all.
for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/cb/); do
    git worktree list --porcelain | grep -qxF "branch refs/heads/$branch" && continue
    if printf '%s\n' "$IN_USE" | grep -qxF "$branch"; then
        echo "keep (held by a worktree mid-rebase): $branch"
        kept=$((kept + 1))
        continue
    fi
    printf '%s\n' "$OPEN_HEADS" | grep -qxF "$branch" && continue
    if is_merged "$branch"; then
        git branch -D "$branch" >/dev/null && echo "removed branch (no worktree): $branch" && removed=$((removed + 1))
    fi
done

git worktree prune
echo "prune done: $removed removed, $kept kept"
