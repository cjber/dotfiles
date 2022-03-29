#!/bin/bash
{%@@ if profile=="home" @@%}
hsetroot -solid "#1a1b26"
xset r rate 500 60
xinput --set-prop 'pointer:Logitech G903 LS' 'libinput Accel Speed' -.70
{%@@ elif profile=="laptop" @@%}
setxkbmap -option caps:escape
{%@@ endif @@%}

