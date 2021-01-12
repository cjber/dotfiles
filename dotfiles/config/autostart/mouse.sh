#!/bin/bash
{%@@ if profile=="home" @@%}
xinput --set-prop 'pointer:Logitech G903 LS' 'libinput Accel Speed' -.75
{%@@ elif profile=="laptop" @@%}
setxkbmap -option caps:escape
{%@@ endif @@%}

