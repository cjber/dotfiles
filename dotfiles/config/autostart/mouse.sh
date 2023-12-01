#!/bin/bash
{%@@ if profile=="home" @@%}
xset r rate 500 60
xinput --set-prop 'pointer:Logitech G903 LS' 'libinput Accel Speed' -.90
{%@@ elif profile=="laptop" @@%}
setxkbmap -option caps:escape
{%@@ endif @@%}

