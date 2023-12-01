#!/bin/bash

LOCAL_DRIVE=$HOME/drive
REMOTE_DRIVE=gdrive:drive
BACKUP=gdrive:backup

LOCAL_DATA=$HOME/data
REMOTE_DATA=gdrive:data

BACKUP_DATA=gdrive:backup_data
EXCLUDE_FILE=$HOME/scripts/exclude.txt
LOG_FILE=$HOME/gdrive_sync.log

LOCAL_TODO=$HOME/drive/todo
REMOTE_TODO=gdrive:todo

if pgrep -fl rclone; then exit 1; fi

/usr/bin/rclone sync "$LOCAL_DRIVE" $REMOTE_DRIVE \
    --exclude-from "$EXCLUDE_FILE" \
    --backup-dir="$BACKUP" \
    --suffix ."$(date +"%Y-%m-%d-%H-%M-%S")" \
    --suffix-keep-extension \
    --progress \
    --verbose \
    --log-file="$LOG_FILE" \
    --max-age $1

/usr/bin/rclone sync "$LOCAL_DATA" $REMOTE_DATA \
    --exclude-from "$EXCLUDE_FILE" \
    --backup-dir="$BACKUP_DATA" \
    --suffix ."$(date +"%Y-%m-%d-%H-%M-%S")" \
    --suffix-keep-extension \
    --progress \
    --verbose \
    --log-file="$LOG_FILE" \
    --max-age $1

/usr/bin/rclone bisync "$LOCAL_TODO" $REMOTE_TODO --resync
