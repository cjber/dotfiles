#!/bin/bash

DRIVE=$HOME/drive
BACKUP=odrive:backup
EXCLUDE_FILE=$HOME/scripts/exclude.txt
LOG_FILE=$HOME/odrive_sync.log

if pgrep -fl rclone; then exit 1; fi

/usr/bin/rclone sync "$DRIVE" odrive:drive \
    --backup-dir="$BACKUP" \
    --suffix ."$(date +"%Y-%m-%d-%H-%M-%S")" \
    --progress \
    --verbose \
    --log-file="$LOG_FILE" \
    --exclude-from "$EXCLUDE_FILE"
