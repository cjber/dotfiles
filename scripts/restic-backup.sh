#!/bin/bash
# Nightly encrypted, versioned backup of /home/cjber to two independent
# destinations via restic: the NAS (SFTP) and a Drive-hosted repo (via
# rclone's gdrive remote as the storage backend). Same source, same
# excludes, same retention - just two repos, so a single point of failure
# in one destination doesn't lose backup coverage.
#
# Previously two separate scripts (restic-backup.sh for the NAS,
# restic-backup-gdrive.sh for Drive, scoped to ~/drive/other only).
# Unified into one: less duplicated config to drift out of sync, and
# Drive now gets the same full /home/cjber coverage as the NAS instead
# of a narrower slice.
#
# NAS repo: sftp:cillian@192.168.0.64:/home/cillian/restic/barry
# Drive repo: rclone:gdrive:restic-backup
#
# After both legs, pushes a status JSON to the NAS's Home Assistant config
# dir (mounted as /config in the HA container) so HA can surface backup
# health without reaching back into this machine - see
# packages/backups.yaml on the NAS.
set -uo pipefail

LOGFILE="/home/cjber/scripts/restic-backup.log"
EXCLUDES="/home/cjber/scripts/restic-excludes.txt"
RESTIC="/usr/bin/restic"
START_EPOCH=$(date +%s)

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOGFILE"; }

# Prints "<backup_exit> <size_bytes>" on stdout; everything else goes to
# LOGFILE, so the caller can cleanly capture just those two values.
backup_to() {
  repo_name="$1"
  repo_uri="$2"
  pass_entry="$3"

  export RESTIC_REPOSITORY="$repo_uri"
  # Password comes from pass (GPG-encrypted store); restic runs this command
  # and uses its stdout. Full paths so it also works under systemd's minimal PATH.
  export RESTIC_PASSWORD_COMMAND="/usr/bin/pass show $pass_entry"

  log "=== $repo_name backup start ==="
  $RESTIC backup /home/cjber \
    --exclude-file "$EXCLUDES" \
    --exclude-caches \
    --tag nightly \
    --host barry >> "$LOGFILE" 2>&1
  backup_exit=$?
  log "$repo_name backup finished (exit=$backup_exit)"

  if [ "$backup_exit" -eq 0 ]; then
    $RESTIC forget --prune \
      --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --keep-yearly 1 \
      >> "$LOGFILE" 2>&1
    log "$repo_name forget/prune finished (exit=$?)"
  fi

  size_bytes=$($RESTIC stats latest --mode raw-data --json 2>>"$LOGFILE" | python3 -c '
import json, sys
try:
    print(json.load(sys.stdin).get("total_size", 0))
except Exception:
    print(0)
')
  [ -z "$size_bytes" ] && size_bytes=0

  unset RESTIC_REPOSITORY RESTIC_PASSWORD_COMMAND
  echo "$backup_exit $size_bytes"
}

read -r NAS_EXIT NAS_SIZE_BYTES <<< "$(backup_to nas "sftp:cillian@192.168.0.64:/home/cillian/restic/barry" \
  "restic/barry")"

read -r GDRIVE_EXIT GDRIVE_SIZE_BYTES <<< "$(backup_to gdrive "rclone:gdrive:restic-backup" \
  "restic/gdrive-backup")"

log "=== all backups done (nas_exit=$NAS_EXIT gdrive_exit=$GDRIVE_EXIT) ==="

# Drive quota, for the "how close to the free-tier ceiling" gauge.
GDRIVE_QUOTA_JSON=$(rclone about gdrive: --json 2>/dev/null || echo '{}')

END_EPOCH=$(date +%s)
DURATION=$((END_EPOCH - START_EPOCH))

STATUS_JSON=$(NAS_EXIT="$NAS_EXIT" GDRIVE_EXIT="$GDRIVE_EXIT" \
  NAS_SIZE_BYTES="$NAS_SIZE_BYTES" GDRIVE_SIZE_BYTES="$GDRIVE_SIZE_BYTES" \
  DURATION="$DURATION" GDRIVE_QUOTA_JSON="$GDRIVE_QUOTA_JSON" \
  python3 -c '
import json, os, datetime
quota = json.loads(os.environ["GDRIVE_QUOTA_JSON"])
print(json.dumps({
    "last_run": datetime.datetime.now().astimezone().isoformat(),
    "duration_seconds": int(os.environ["DURATION"]),
    "nas_exit": int(os.environ["NAS_EXIT"]),
    "gdrive_exit": int(os.environ["GDRIVE_EXIT"]),
    "nas_size_bytes": int(os.environ["NAS_SIZE_BYTES"]),
    "gdrive_size_bytes": int(os.environ["GDRIVE_SIZE_BYTES"]),
    "gdrive_quota_used_bytes": quota.get("used", 0),
    "gdrive_quota_total_bytes": quota.get("total", 0),
}))
' 2>>"$LOGFILE")

if [ -n "$STATUS_JSON" ]; then
  echo "$STATUS_JSON" | ssh cillian@192.168.0.64 \
    "cat > /volume1/docker/homeassistant/config/backup_status.json" >> "$LOGFILE" 2>&1
  log "status JSON pushed to NAS (exit=$?)"
else
  log "WARNING: failed to build status JSON, not pushed"
fi

[ "$NAS_EXIT" -eq 0 ] && [ "$GDRIVE_EXIT" -eq 0 ]
