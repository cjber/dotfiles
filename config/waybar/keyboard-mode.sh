#!/bin/sh

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
state_file="$state_dir/zerosprey42-mode"

# Hyprland 0.56 rejects `hyprctl keyword` outright -- "keyword can't work with
# non-legacy parsers. Use eval." -- because the config is Lua now. Every colour
# and allow_tearing line here used to be a silent no-op, so game mode only ever
# managed to toggle mako's do-not-disturb. That is what made the indicator look
# inverted: the pill said game, the desktop stayed base, and notifications went
# quiet with no visible reason.
#
# `hyprctl eval` runs Lua against the live config, and hl.config() takes the
# same nested table shape as hyprland.lua itself.
apply_desktop_mode() {
    mode=$1
    if [ "$mode" = "game" ]; then
        active='rgba(e78a53ff)'
        inactive='rgba(4a2d22ff)'
        locked='rgba(fbcb97ff)'
        tearing=true
    else
        active='rgba(5f8787ff)'
        inactive='rgba(222222ff)'
        locked='rgba(8fbabaff)'
        tearing=false
    fi

    hyprctl eval "hl.config({
        general = {
            col = {
                active_border        = '$active',
                inactive_border      = '$inactive',
                nogroup_border       = '$inactive',
                nogroup_border_active= '$active',
            },
            allow_tearing = $tearing,
        },
        group = {
            col = {
                border_active         = '$active',
                border_inactive       = '$inactive',
                border_locked_active  = '$locked',
                border_locked_inactive= '$inactive',
            },
            groupbar = {
                col = {
                    active         = '$active',
                    inactive       = '$inactive',
                    locked_active  = '$locked',
                    locked_inactive= '$inactive',
                },
            },
        },
    })" >/dev/null

    if [ "$mode" = "game" ]; then
        makoctl mode -a do-not-disturb >/dev/null 2>&1 || true
    else
        makoctl mode -r do-not-disturb >/dev/null 2>&1 || true
    fi
}

mkdir -p "$state_dir"

if [ "${1:-}" = "apply" ]; then
    mode=$(cat "$state_file" 2>/dev/null)
    [ "$mode" = "game" ] || mode=base
    apply_desktop_mode "$mode"
    # The waybar module has no interval -- it renders once and then only on
    # RTMIN+12. Without this, a re-apply fixes the desktop but leaves the pill
    # showing whatever it last drew.
    pkill -RTMIN+12 waybar 2>/dev/null || true
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
