#!/bin/bash
# Daily, HOME-scoped disk hygiene — the counterpart to the ROOT timers that
# already cover the system (paccache.timer weekly, container-cleanup.timer
# daily, docker-cleanup.timer weekly, fstrim/scrub/balance) and to
# wt-cleanup.sh, which owns ~/.worktrees. Nothing owned the caches HOME grows
# on its own, which is how ~/.codex (18G) and ~/.claude (15G) grew unwatched
# and ~/.cache/uv reached 10G.
#
# Everything removed here is regenerable: a rebuild, a re-download, or a
# re-run. Nothing under a repo working tree is touched — that is wt-cleanup's
# job and it can hold uncommitted work.
#
# `set -o pipefail` only, deliberately no `-e`: one unavailable cache must not
# abort the rest of the pass. Every step is individually guarded.
set -uo pipefail
export PATH=/usr/bin:/usr/local/bin:/bin:${PATH:-}

RETENTION_DAYS="${DISK_HYGIENE_RETENTION_DAYS:-14}"
WARN_FREE_GB="${DISK_HYGIENE_WARN_FREE_GB:-60}"
LOG_SOFT_CAP_BYTES=52428800   # 50M: truncate a runaway log down to 5M
LOG_KEEP_BYTES=5242880
JOBS_DIR="$HOME/.claude/jobs"

log() { printf '[disk-hygiene] %s\n' "$*"; }
free_gb() { df -BG --output=avail / | tail -1 | tr -dc '0-9'; }

log "=== $(date -Is) start; free $(free_gb)G"

# --- free-space watchdog -----------------------------------------------------
# / last filled to 95% with nothing having warned. A line here plus a desktop
# notification gives a day of warning instead of a surprise ENOSPC.
f="$(free_gb)"
if [ "${f:-0}" -lt "$WARN_FREE_GB" ]; then
  log "WARNING: only ${f}G free (threshold ${WARN_FREE_GB}G)"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical "Disk low on /" "${f}G free" || true
  fi
fi

# --- uv ---------------------------------------------------------------------
# One shared archive cache; prune is safe. It refuses while any uv process holds
# the lock (dev servers, evals are usually running), so skip rather than use
# --force, which can corrupt a running process's cache.
if command -v uv >/dev/null 2>&1; then
  if UV_LOCK_TIMEOUT=5 uv cache prune >/dev/null 2>&1; then
    log "uv: cache pruned"
  else
    log "uv: cache in use — skipped"
  fi
fi

# --- agent-CLI state older than RETENTION_DAYS -------------------------------
# Transcripts/sessions only. The sqlite history and config files stay — they are
# the queryable record; the jsonl transcripts are bulk.
prune_older() { # <dir> [find args...]
  local d="$1"; shift
  [ -d "$d" ] || return 0
  local n
  n="$(find "$d" "$@" -mtime +"$RETENTION_DAYS" -delete -print 2>/dev/null | wc -l)"
  [ "${n:-0}" -gt 0 ] && log "${d#$HOME/}: removed $n files >${RETENTION_DAYS}d"
  return 0
}
prune_older "$HOME/.codex/sessions" -type f -name '*.jsonl'
prune_older "$HOME/.codex/archived_sessions" -type f
prune_older "$HOME/.claude/projects" -type f
prune_older "$HOME/.claude/jobs" -type f
prune_older "$HOME/.claude/file-history" -type f
# Reap directories left empty by the deletions above.
find "$HOME/.codex/sessions" "$HOME/.codex/archived_sessions" \
     "$HOME/.claude/projects" "$HOME/.claude/file-history" \
     -type d -empty -delete 2>/dev/null || true

# --- pinned job scratch spaces ----------------------------------------------
# .claude/jobs/<id>/tmp is a scratch clone. Reap it only when the JOB itself is
# past retention, so an in-flight job is never disturbed (a live job's tmp can
# hold a running container/clone).
if [ -d "$JOBS_DIR" ]; then
  while IFS= read -r t; do
    [ -d "$t" ] || continue
    rm -rf -- "$t" && log "claude job scratch reaped: ${t#$HOME/}"
  done < <(find "$JOBS_DIR" -mindepth 2 -maxdepth 2 -type d -name tmp \
             -mtime +"$RETENTION_DAYS" 2>/dev/null)
fi

# --- runaway appender logs ---------------------------------------------------
# Hourly cron appends to these and nothing rotates them.
for l in "$HOME/scripts/gdrive_sync.log" "$HOME/scripts/restic-backup.log"; do
  [ -f "$l" ] || continue
  sz="$(stat -c%s "$l" 2>/dev/null || echo 0)"
  if [ "$sz" -gt "$LOG_SOFT_CAP_BYTES" ]; then
    if tail -c "$LOG_KEEP_BYTES" "$l" > "$l.tmp" 2>/dev/null && mv "$l.tmp" "$l"; then
      log "truncated $(basename "$l") ($((sz / 1048576))M -> 5M)"
    fi
  fi
done

log "=== done; free $(free_gb)G"
