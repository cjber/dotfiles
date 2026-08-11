#!/bin/bash
# Keep a repo's PRIMARY checkout on `main`, fast-forwarded to origin/main.
#
# Enforces worktree invariant 2: the main dir is always on `main`, never a
# feature branch. All feature work belongs in ~/.worktrees/<repo>/cb-<feature>.
#
# Safety contract — this script never destroys work:
#   * fast-forward ONLY (`merge --ff-only`). Never reset --hard, never rebase,
#     never force. Local commits on main make it fail loudly, not clobber.
#   * it only switches back to main from a feature branch when the working tree
#     is CLEAN and that branch is safe to leave (pushed, or no commits of its
#     own). Dirty or unpushed => it warns and leaves everything alone.
#   * a stash is never created, so there is no hidden state to recover.
#
# Usage: freshen.sh [repo-path]   (defaults to $PWD)
set -euo pipefail
export PATH=/usr/bin:/usr/local/bin:/bin:${PATH:-}

repo="${1:-$PWD}"
log() { printf '[freshen] %s\n' "$*"; }
warn() { printf '[freshen] WARNING: %s\n' "$*" >&2; }

[[ -d "$repo/.git" || -f "$repo/.git" ]] || { warn "$repo is not a repo"; exit 0; }

# Refuse to run against a worktree — this script is about the PRIMARY checkout.
# `git rev-parse --git-common-dir` differs from --git-dir inside a worktree.
gitdir=$(git -C "$repo" rev-parse --absolute-git-dir)
commondir=$(cd "$repo" && cd "$(git rev-parse --git-common-dir)" && pwd)
if [[ "$gitdir" != "$commondir" ]]; then
    warn "$repo is a worktree, not the primary checkout — skipping"
    exit 0
fi

name=$(basename "$repo")

git -C "$repo" fetch --quiet --prune origin || { warn "$name: fetch failed"; exit 0; }

# Determine the remote's default branch rather than assuming `main`.
main_branch=$(git -C "$repo" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
[[ -n "$main_branch" ]] || main_branch=main
git -C "$repo" show-ref --verify --quiet "refs/remotes/origin/$main_branch" || {
    warn "$name: origin/$main_branch missing — skipping"; exit 0; }

# Restore the local main ref if it vanished (the classic worktree-tool footgun).
if ! git -C "$repo" show-ref --verify --quiet "refs/heads/$main_branch"; then
    warn "$name: local $main_branch was missing — recreating from origin/$main_branch"
    git -C "$repo" branch "$main_branch" "origin/$main_branch"
fi

current=$(git -C "$repo" rev-parse --abbrev-ref HEAD)

# --- Invariant 2: the primary checkout must sit on the default branch ---------
if [[ "$current" != "$main_branch" ]]; then
    warn "$name: primary checkout is on '$current', not '$main_branch' (feature work belongs in ~/.worktrees)"

    # `-uno`: untracked files are never a reason to stop. They survive a
    # checkout untouched, and git itself refuses any checkout that would
    # clobber one — so only modified TRACKED files mean "someone is working".
    if [[ -n "$(git -C "$repo" status --porcelain -uno)" ]]; then
        warn "  tracked files are modified — NOT switching. Commit or move this to a worktree."
        exit 0
    fi
    # Only leave the branch behind if nothing would be lost: it must be either
    # fully pushed to its upstream, or contain no commits beyond the base.
    upstream=$(git -C "$repo" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)
    if [[ -n "$upstream" ]]; then
        unpushed=$(git -C "$repo" rev-list --count "$upstream..HEAD")
    else
        unpushed=$(git -C "$repo" rev-list --count "origin/$main_branch..HEAD")
    fi
    if (( unpushed > 0 )); then
        warn "  '$current' has $unpushed unpushed commit(s) — NOT switching. Push it or move it to a worktree first."
        exit 0
    fi
    log "  '$current' is clean and fully pushed — returning to $main_branch"
    git -C "$repo" checkout --quiet "$main_branch"
    current="$main_branch"
fi

# --- Fast-forward main to origin/main ----------------------------------------
behind=$(git -C "$repo" rev-list --count "HEAD..origin/$main_branch")
ahead=$(git -C "$repo" rev-list --count "origin/$main_branch..HEAD")

if (( ahead > 0 )); then
    warn "$name: local $main_branch is $ahead commit(s) AHEAD of origin — not fast-forwarding. Resolve by hand."
    exit 0
fi
if (( behind == 0 )); then
    log "$name: $main_branch already up to date"
    exit 0
fi
if [[ -n "$(git -C "$repo" status --porcelain -uno)" ]]; then
    warn "$name: $main_branch is $behind behind but tracked files are modified — not fast-forwarding"
    exit 0
fi

# If an untracked file would be overwritten, git refuses here and says which —
# that is the correct outcome, so let the failure surface rather than pre-empt it.
git -C "$repo" merge --quiet --ff-only "origin/$main_branch"
log "$name: $main_branch fast-forwarded $behind commit(s) to $(git -C "$repo" rev-parse --short HEAD)"
