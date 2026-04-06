#!/bin/bash

if ! systemctl --user is-enabled gdrive.timer &>/dev/null; then
    echo '{"text":"󰅟 off","class":"disconnected","tooltip":"Google Drive sync is disabled"}'
    exit 0
fi

if pgrep -x rclone >/dev/null 2>&1; then
    echo '{"text":"󰅟 syncing","class":"syncing","tooltip":"Google Drive sync in progress"}'
    exit 0
fi

if systemctl --user is-failed gdrive.service &>/dev/null; then
    echo '{"text":"󰅟 failed","class":"warning","tooltip":"Google Drive last sync failed"}'
    exit 0
fi

last=$(systemctl --user show gdrive.timer --property=LastTriggerUSec --value 2>/dev/null)
last_fmt=$(date -d "$last" +"%H:%M" 2>/dev/null || echo "n/a")
tooltip="Google Drive sync idle\nLast sync: ${last_fmt}"
echo "{\"text\":\"󰅟\",\"class\":\"connected\",\"tooltip\":\"${tooltip}\"}"
