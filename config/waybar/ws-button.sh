#!/usr/bin/env bash
# Waybar module: a single clickable workspace button.
#
# Replaces waybar's built-in hyprland/workspaces, whose clicks are broken on
# Hyprland 0.56: waybar v0.15.0 still sends the hyprlang-era `dispatch
# workspace N`, and 0.56 is Lua-only, so every click errors with
#   [string "return hl.dispatch(workspace 1)"]:1: ')' expected near '1'
# The click handler in main.jsonc uses the Lua form instead, which works.
#
# Usage: ws-button.sh <workspace-number>
# Emits {"text","class","tooltip"} where class is active | occupied | empty.

set -uo pipefail

WS="${1:?usage: ws-button.sh <workspace-number>}"

RT="${XDG_RUNTIME_DIR:-/tmp}"
LAST=""

render() {
    local out
    out=$(hyprctl -j workspaces 2>/dev/null | python3 -c "
import json, subprocess, sys

ws = int('$WS')

try:
    spaces = json.load(sys.stdin)
except Exception:
    spaces = []

active = None
try:
    mons = json.loads(subprocess.run(
        ['hyprctl', '-j', 'monitors'], capture_output=True, text=True, timeout=3
    ).stdout)
    # The button should light up for the workspace visible on its own monitor,
    # not only the focused one, so a glance shows both screens' state.
    for m in mons:
        if m.get('activeWorkspace', {}).get('id') == ws:
            active = m.get('name')
            break
except Exception:
    pass

count = 0
for s in spaces:
    if s.get('id') == ws:
        count = s.get('windows', 0)
        break

if active:
    cls, tip = 'active', 'workspace %d (on %s)' % (ws, active)
elif count:
    cls, tip = 'occupied', 'workspace %d - %d window(s)' % (ws, count)
else:
    cls, tip = 'empty', 'workspace %d - empty' % ws

print(json.dumps({'text': str(ws), 'class': cls, 'tooltip': tip}))
")
    [[ -z "$out" || "$out" == "$LAST" ]] && return
    LAST="$out"
    printf '%s\n' "$out"
}

render

SOCK="$RT/hypr/${HYPRLAND_INSTANCE_SIGNATURE:-}/.socket2.sock"
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" && -S "$SOCK" ]] && command -v socat >/dev/null; then
    socat -u UNIX-CONNECT:"$SOCK" - 2>/dev/null | while read -r line; do
        case "$line" in
        workspace* | focusedmon* | openwindow* | closewindow* | movewindow* | \
            createworkspace* | destroyworkspace*)
            render
            ;;
        esac
    done
else
    while sleep 2; do render; done
fi
