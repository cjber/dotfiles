#!/bin/sh
killall -q polybar


# Wait until the processes have been shut down
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

MONITOR=$(polybar --list-monitors | cut -d":" -f1 | head -n 1) polybar --reload top &
