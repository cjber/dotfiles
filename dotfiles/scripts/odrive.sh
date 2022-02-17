#!/bin/bash

DRIVE=$HOME/drive
EXCLUDE_FILE=$HOME/scripts/exclude.txt
BACKUP=$HOME/backup

if pidof -o %PPID -x "odrive.sh"; then exit 1; fi

/usr/bin/rclone sync /home/cjber/drive od:drive --exclude-from exclude.txt --delete-excluded

/usr/bin/rclone copy -u -v od:/drive "$DRIVE" \
    --backup-dir "$BACKUP" \
    --suffix ."$(date +"%Y-%m-%d-%H-%M-%S")"

/usr/bin/rclone sync -v "$DRIVE" od:/drive --exclude-from "$EXCLUDE_FILE"
