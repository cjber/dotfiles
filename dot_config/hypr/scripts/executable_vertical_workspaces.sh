#!/bin/sh

# Get a JSON of all monitors using hyprctl monitors -j
ALL_MONITORS=$(hyprctl monitors -j)
# Filter out only the monitors that have a transform property of 1
VERTICAL_MONITORS=$(echo $ALL_MONITORS | jq '.[] | select(.transform == 1)')
# Get the names of vertical monitors
VERTICAL_MONITOR_NAMES=$(echo $VERTICAL_MONITORS | jq -r '.name')

handle() {
    case $1 in
        focusedmon*)
            if [[ $line == "focusedmon>>$VERTICAL_MONITOR_NAMES"* ]]; then
                hyprctl dispatch "layoutmsg orientationtop" > /dev/null  # Redirect "ok" to /dev/null
            else
                hyprctl dispatch "layoutmsg orientationcenter" > /dev/null  # Redirect "ok" to /dev/null
            fi ;;
    esac
}

socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
