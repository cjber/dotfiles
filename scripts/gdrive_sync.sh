#!/bin/bash
# Pure live mirror: ~/drive -> gdrive:drive, for convenience access from other
# devices (phone/web). NOT a backup - safety/history is restic's job now
# (restic-backup.sh to the NAS, restic-backup-gdrive.sh to Drive itself).
#
# Previously this also used --backup-dir/--max-age as a poor-man's backup.
# --max-age 7d + --delete-excluded silently deleted anything untouched for
# a week (treated as "excluded" by the age filter, then removed by
# --delete-excluded) with no way to resurface it. That's what wiped
# other/ and several agl/ dirs. Removed both flags; restic now owns
# retention/history instead of an unbounded pile of dated backup-dir folders.
#
# No --fast-list: it does one bulk recursive listing of the whole remote
# tree and applies filters client-side afterward, so it can't skip
# excluded subtrees. Plain per-directory listing respects filters during
# the walk and actually skips descending into /agl/** (by far the
# largest, and fully excluded below), which is what makes this fast.

LOCAL_DRIVE=$HOME/drive
REMOTE_DRIVE=gdrive:drive

EXCLUDE_FILE=$HOME/scripts/exclude.txt

if pgrep -fl rclone; then exit 1; fi

/usr/bin/rclone sync "$LOCAL_DRIVE" $REMOTE_DRIVE \
    --filter-from "$EXCLUDE_FILE" \
    --transfers 16 \
    --checkers 16 \
    --drive-chunk-size 64M \
    --progress \
    --verbose
