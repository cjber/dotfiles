#!/bin/sh

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
state_file="$state_dir/zerosprey42-mode"

apply_desktop_mode() {
    mode=$1
    if [ "$mode" = "game" ]; then
        active='rgba(e78a53ff)'
        inactive='rgba(4a2d22ff)'
        locked='rgba(fbcb97ff)'
        hyprctl --batch "keyword general:col.active_border $active ; keyword general:col.inactive_border $inactive ; keyword general:col.nogroup_border $inactive ; keyword general:col.nogroup_border_active $active ; keyword group:col.border_active $active ; keyword group:col.border_inactive $inactive ; keyword group:col.border_locked_active $locked ; keyword group:col.border_locked_inactive $inactive ; keyword group:groupbar:col.active $active ; keyword group:groupbar:col.inactive $inactive ; keyword group:groupbar:col.locked_active $locked ; keyword group:groupbar:col.locked_inactive $inactive ; keyword general:allow_tearing true ; keyword misc:vrr 2" >/dev/null
        makoctl mode -a do-not-disturb >/dev/null 2>&1 || true
    else
        active='rgba(5f8787ff)'
        inactive='rgba(222222ff)'
        locked='rgba(8fbabaff)'
        hyprctl --batch "keyword general:col.active_border $active ; keyword general:col.inactive_border $inactive ; keyword general:col.nogroup_border $inactive ; keyword general:col.nogroup_border_active $active ; keyword group:col.border_active $active ; keyword group:col.border_inactive $inactive ; keyword group:col.border_locked_active $locked ; keyword group:col.border_locked_inactive $inactive ; keyword group:groupbar:col.active $active ; keyword group:groupbar:col.inactive $inactive ; keyword group:groupbar:col.locked_active $locked ; keyword group:groupbar:col.locked_inactive $inactive ; keyword general:allow_tearing false ; keyword misc:vrr 2" >/dev/null
        makoctl mode -r do-not-disturb >/dev/null 2>&1 || true
    fi
}

mkdir -p "$state_dir"

if [ "${1:-}" = "apply" ]; then
    mode=$(cat "$state_file" 2>/dev/null)
    [ "$mode" = "game" ] || mode=base
    apply_desktop_mode "$mode"
    exit 0
fi

if [ "${1:-}" = "toggle" ]; then
    if [ "$(cat "$state_file" 2>/dev/null)" = "game" ]; then
        printf '%s\n' base > "$state_file"
    else
        printf '%s\n' game > "$state_file"
    fi
    mode=$(cat "$state_file")
    if [ "$mode" = "game" ]; then
        notify-send -a "keyboard mode" -u low -t 1800 "game mode" "alt ⇄ super · gaming desktop enabled"
    fi
    apply_desktop_mode "$mode"
    if [ "$mode" = "base" ]; then
        notify-send -a "keyboard mode" -u low -t 1800 "base mode" "standard modifiers · desktop restored"
    fi
    pkill -RTMIN+12 waybar 2>/dev/null || true
    exit 0
fi

mode=$(cat "$state_file" 2>/dev/null)
if [ "$mode" = "game" ]; then
    printf '%s\n' '{"text":"<span alpha=\"70%\">z42</span>  <b>game</b>  <span alpha=\"65%\">alt⇄super · l0</span>","class":"game","tooltip":"Zerosprey42 · Game mode\nAlt and Super are swapped\nLayer 0 is the persistent base"}'
else
    [ "$mode" = "base" ] || printf '%s\n' base > "$state_file"
    printf '%s\n' '{"text":"<span alpha=\"70%\">z42</span>  <b>base</b>  <span alpha=\"65%\">standard · l0</span>","class":"base","tooltip":"Zerosprey42 · Base mode\nStandard Alt and Super\nLayer 0 is the persistent base"}'
fi
