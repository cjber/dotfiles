#!/bin/sh
killall -q polybar


# Wait until the processes have been shut down
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

MONITOR=DP-2 polybar --reload top &

# for m in $(polybar --list-monitors | cut -d":" -f1); do
#     MONITOR=$m polybar --reload top &
# done
