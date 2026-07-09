#!/bin/bash
# Pure live mirror: ~/drive -> gdrive:drive, for convenience access from other
# devices (phone/web). NOT a backup - safety/history is restic's job now
# (unified restic-backup.sh backs up all of /home/cjber to both the NAS
# and a Drive-hosted repo).
#
# Previously this also used --backup-dir/--max-age as a poor-man's backup.
# --max-age 7d + --delete-excluded silently deleted anything untouched for
# a week (treated as "excluded" by the age filter, then removed by
# --delete-excluded) with no way to resurface it. That's what wiped
# other/ and several agl/ dirs. Removed both flags; restic now owns
# retention/history instead of an unbounded pile of dated backup-dir folders.
#
# Full ~/drive mirrored, agl/ included - --fast-list does one bulk
# recursive listing of the whole remote tree rather than walking
# directory-by-directory, which is the faster option now that nothing
# is being excluded/pruned.

LOCAL_DRIVE=$HOME/drive
REMOTE_DRIVE=gdrive:drive

EXCLUDE_FILE=$HOME/scripts/exclude.txt

if pgrep -fl rclone; then exit 1; fi

/usr/bin/rclone sync "$LOCAL_DRIVE" $REMOTE_DRIVE \
    --filter-from "$EXCLUDE_FILE" \
    --fast-list \
    --transfers 16 \
    --checkers 16 \
    --drive-chunk-size 64M \
    --progress \
    --verbose
SYNC_EXIT=$?

# Push status to the NAS's HA config dir (mirrors restic-backup.sh's
# pattern) so HA can alert if this hasn't run successfully in a while -
# exactly the kind of silent failure that caused the original incident.
python3 -c "
import json, datetime
print(json.dumps({
    'last_run': datetime.datetime.now().astimezone().isoformat(),
    'exit_code': $SYNC_EXIT,
}))
" | ssh cillian@192.168.0.64 "cat > /volume1/docker/homeassistant/config/sync_status.json" >/dev/null 2>&1

exit $SYNC_EXIT
