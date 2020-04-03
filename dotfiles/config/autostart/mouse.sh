#!/bin/bash
{%@@ if profile=="home" @@%}
xinput --set-prop 'pointer:Razer Razer Abyssus V2' 'libinput Accel Speed' -.75
{%@@ elif profile=="laptop" @@%}
setxkbmap -option caps:escape
{%@@ endif @@%}

