#!/bin/bash
{%@@ if profile=="home" @@%}
hsetroot -solid "#1a1b26"
xset r rate 500 60
xrandr --output DP-2 --mode 3440x1440 --rate 144 --output HDMI-0 --mode 2560x1440 --rate 60.00 --rotate left --right-of DP-2
xinput --set-prop 'pointer:Logitech G903 LS' 'libinput Accel Speed' -.70
{%@@ elif profile=="laptop" @@%}
setxkbmap -option caps:escape
{%@@ endif @@%}

