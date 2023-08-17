#!/bin/bash

DRIVE=$HOME/drive
BACKUP=odrive:backup
EXCLUDE_FILE=$HOME/scripts/exclude.txt
LOG_FILE=$HOME/scripts/odrive_sync.log

if pgrep -fl rclone; then exit 1; fi

/usr/bin/rclone sync "$DRIVE" odrive:drive \
    --max-age 24h \
    --no-traverse \
    --backup-dir="$BACKUP" \
    --suffix ."$(date +"%Y-%m-%d-%H-%M-%S")" \
    --suffix-keep-extension \
    --progress \
    --verbose \
    --log-file="$LOG_FILE" \
    --exclude-from "$EXCLUDE_FILE" \
