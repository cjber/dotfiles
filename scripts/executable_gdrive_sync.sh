#!/bin/bash

LOCAL_DRIVE=$HOME/drive
REMOTE_DRIVE=gdrive:drive

EXCLUDE_FILE=$HOME/scripts/exclude.txt

BACKUP_TIMESTAMP=$(date +"%Y-%m-%d")
BACKUP_DIR="gdrive:backup/$BACKUP_TIMESTAMP"

if pgrep -fl rclone; then exit 1; fi

/usr/bin/rclone sync "$LOCAL_DRIVE" $REMOTE_DRIVE \
    --filter-from "$EXCLUDE_FILE" \
    --delete-excluded \
    --fast-list \
    --transfers 16 \
    --checkers 16 \
    --drive-chunk-size 64M \
    --progress \
    --verbose \
    --backup-dir $BACKUP_DIR \
    --suffix ."$(date +"%Y-%m-%d-%H-%M-%S")" \
    --suffix-keep-extension \
    --max-age 7d
