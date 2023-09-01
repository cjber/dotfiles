#!/bin/bash

LOCAL_DRIVE=$HOME/drive
REMOTE_DRIVE=odrive:drive

BACKUP=odrive:backup
EXCLUDE_FILE=$HOME/scripts/exclude.txt
LOG_FILE=$HOME/odrive_sync.log

if pgrep -fl rclone; then exit 1; fi

/usr/bin/rclone sync "$LOCAL_DRIVE" $REMOTE_DRIVE \
    --max-age 24h \
    --backup-dir="$BACKUP" \
    --suffix ."$(date +"%Y-%m-%d-%H-%M-%S")" \
    --suffix-keep-extension \
    --progress \
    --verbose \
    --log-file="$LOG_FILE" \
    --exclude-from "$EXCLUDE_FILE" \
