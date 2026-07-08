#!/bin/bash
# Keep ~/dotfiles continuously in sync with dotter deployment and the GitHub remote.
# Runs on a systemd user timer. Because dotter uses symlinks, edits to deployed
# config files land directly in the repo, so this just needs to deploy, commit, pull, push.
set -uo pipefail

REPO="/home/cjber/dotfiles"
LOGFILE="$REPO/.git/dotfiles-sync.log"
cd "$REPO" || exit 1

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOGFILE"; }

# 1. Ensure links are current (non-fatal: repo sync must proceed even if deploy hiccups).
dotter deploy >> "$LOGFILE" 2>&1 || log "WARN: dotter deploy returned non-zero"

# 2. Commit any local changes.
git add -A
if ! git diff --cached --quiet; then
  # Signing disabled: runs headless from a timer with no pinentry. Manual commits stay signed.
  git -c commit.gpgsign=false commit -q -m "chore(dotfiles): auto-sync $(hostname) $(date '+%Y-%m-%d %H:%M')" >> "$LOGFILE" 2>&1
  log "committed local changes"
fi

# 3. Integrate remote changes, then push.
git pull --rebase --autostash origin main >> "$LOGFILE" 2>&1 || { log "ERROR: git pull --rebase failed"; exit 1; }
if [ -n "$(git log origin/main..HEAD 2>/dev/null)" ]; then
  git push origin main >> "$LOGFILE" 2>&1 && log "pushed to origin/main" || { log "ERROR: git push failed"; exit 1; }
fi
