#!/usr/bin/env bash
# Hold a systemd idle inhibitor while any game controller is in use.
# hypridle respects systemd-inhibit --what=idle by default, so the
# screen will not lock as long as this script is holding the lock.
set -euo pipefail
shopt -s nullglob

DEV_GLOB="${CONTROLLER_DEV_GLOB:-/dev/input/js*}"
TIMEOUT="${CONTROLLER_IDLE_TIMEOUT:-180}"  # release inhibit N seconds after last input

STAMP=$(mktemp)
touch -d "@0" "$STAMP"  # start "ancient" so we don't inhibit on launch

declare -A READER_PIDS
INHIBIT_PID=

cleanup() {
    for pid in "${READER_PIDS[@]}"; do
        kill "$pid" 2>/dev/null || true
    done
    [ -n "$INHIBIT_PID" ] && kill "$INHIBIT_PID" 2>/dev/null || true
    rm -f "$STAMP"
}
trap cleanup EXIT INT TERM

# Spawn a blocking reader per controller; re-runs cover hotplug.
spawn_readers() {
    for dev in $DEV_GLOB; do
        local pid="${READER_PIDS[$dev]:-}"
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            continue
        fi
        (
            # each joystick event is 8 bytes; exits when device disappears
            while dd if="$dev" bs=8 count=1 status=none of=/dev/null 2>/dev/null; do
                touch "$STAMP"
            done
        ) &
        READER_PIDS[$dev]=$!
    done
}

while true; do
    spawn_readers

    age=$(( $(date +%s) - $(stat -c %Y "$STAMP") ))
    if [ "$age" -lt "$TIMEOUT" ]; then
        if [ -z "$INHIBIT_PID" ] || ! kill -0 "$INHIBIT_PID" 2>/dev/null; then
            systemd-inhibit --what=idle --who=gaming-controller \
                --why="controller active" sleep infinity &
            INHIBIT_PID=$!
        fi
    else
        if [ -n "$INHIBIT_PID" ] && kill -0 "$INHIBIT_PID" 2>/dev/null; then
            kill "$INHIBIT_PID" 2>/dev/null || true
            INHIBIT_PID=
        fi
    fi
    sleep 5
done
