#!/usr/bin/env bash
# Hands the current branch to a background Claude session on the NAS, for when
# this machine is about to shut down. Run from inside the repo's worktree.
#
#   nas-handoff.sh <brief.md> [slug]
#
# The brief is the session's whole prompt: goal, PR/branch, done, left,
# decisions. slug defaults to the branch name minus its cb/ prefix.
set -euo pipefail

brief="${1:?usage: nas-handoff.sh <brief.md> [slug]}"
[ -s "$brief" ] || { echo "nas-handoff: brief $brief is empty or missing" >&2; exit 1; }
branch=$(git branch --show-current)
[ -n "$branch" ] || { echo "nas-handoff: detached HEAD, check out a branch first" >&2; exit 1; }
slug="${2:-${branch#cb/}}"
slug="${slug//\//-}"
repo=$(basename "$(git remote get-url origin)" .git)
wt="code/wt-$slug"
nas=nas
say() { printf '\033[1m%s\033[0m\n' "$*"; }
rsh() { ssh "$nas" "bash -lc $(printf '%q' "$1")" 2>&1 | grep -v -e 'post-quantum' -e 'store now' -e 'openssh.com/pq'; }

say "snapshot: signed WIP commit of tracked changes"
# Tracked files only: .env and other ignored or untracked files never ride along.
if ! git diff --quiet HEAD; then
    git add -u
    git commit -S -n -q -m "wip: hand off $slug to the NAS"
fi
git push -q --force-with-lease -u origin "$branch"
echo "pushed $(git log -1 --format='%h %G?' "origin/$branch")"

say "nas: worktree ~/$wt"
# The NAS primary checkout may belong to another session: fetch into it, never
# check anything out there. A repo the NAS has never seen is cloned first.
rsh "set -e
     [ -d ~/code/$repo ] || gh repo clone agent-labs-dev/$repo ~/code/$repo -- -q
     cd ~/code/$repo && git fetch -q origin $branch
     if [ -d ~/$wt ]; then git -C ~/$wt pull -q --ff-only
     else git worktree add -q ~/$wt -B $branch origin/$branch; fi
     cp -n ~/code/$repo/.env ~/$wt/.env 2>/dev/null || true
     cd ~/$wt && { [ ! -f pyproject.toml ] || uv sync -q; } && git log -1 --oneline"

say "nas: brief + launch"
tar cf - -C "$(dirname "$brief")" "$(basename "$brief")" |
    ssh "$nas" "mkdir -p ~/code/handoff && tar xf - -O > ~/code/handoff/$slug.md" 2>/dev/null
rsh "cd ~/$wt && claude --bg --name $slug --permission-mode auto \"\$(cat ~/code/handoff/$slug.md)\" < /dev/null"
