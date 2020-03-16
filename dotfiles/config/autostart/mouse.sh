#!/bin/bash
{%@@ if profile=="home" @@%}
xinput --set-prop 14 'libinput Accel Speed' -.75
{%@@ elif profile=="laptop" @@%}
setxkbmap -option caps:escape
{%@@ endif @@%}

