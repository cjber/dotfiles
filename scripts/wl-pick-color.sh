#!/bin/bash
# Wayland-native color picker. Compositor-agnostic (uses wlr-screencopy).
# Click a pixel; the hex color is copied to the clipboard.
set -e

COLOR=$(grim -g "$(slurp -p)" -t ppm - \
    | magick - -format '%[pixel:p{0,0}]' txt:- \
    | tail -n1 | awk '{print $3}')

[ -z "$COLOR" ] && exit 1
printf '%s' "$COLOR" | wl-copy
command -v notify-send >/dev/null && notify-send "Picked color" "$COLOR"
