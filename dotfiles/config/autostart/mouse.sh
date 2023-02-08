#!/bin/bash
{%@@ if profile=="home" @@%}
xset r rate 500 60
xinput --set-prop 'pointer:Logitech G903 LS' 'libinput Accel Speed' -.70
hsetroot -solid "#1a1b26"
hsetroot -solid "#1a1b26"
{%@@ elif profile=="laptop" @@%}
setxkbmap -option caps:escape
hsetroot -solid "#1a1b26"
{%@@ endif @@%}

