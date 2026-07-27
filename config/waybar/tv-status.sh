#!/usr/bin/env bash
# Waybar module: Hisense TV (HDMI-A-1) state.
#
# main.jsonc has referenced this script since the tv-status module was added,
# but it was never created -- waybar logged "No such file or directory" every
# 5s and the module rendered empty. style.css already defines .off / .idle /
# .gaming / .bigpicture, so those are the classes emitted here.
#
# "On" mirrors tv-toggle exactly: the TV counts as on when Hyprland lists the
# output, which is the condition tv-toggle branches on.

set -uo pipefail

TV=HDMI-A-1

# Empty text when the TV is off, which waybar renders as a hidden module. The
# TV is off almost all the time, so a permanent "TV off" pill was noise; the
# on-click toggle is not lost with it, since mod+SHIFT+t runs the same script.
if ! hyprctl monitors 2>/dev/null | grep -q "Monitor $TV"; then
    printf '{"text":"","tooltip":"TV off","class":"off"}\n'
    exit 0
fi

hyprctl -j clients 2>/dev/null | python3 -c '
import json, re, subprocess, sys

TV = "HDMI-A-1"

try:
    clients = json.load(sys.stdin)
except Exception:
    clients = []

mode = ""
try:
    mons = json.loads(subprocess.run(
        ["hyprctl", "-j", "monitors"], capture_output=True, text=True, timeout=3
    ).stdout)
    for m in mons:
        if m.get("name") == TV:
            mode = "%dx%d@%.0f" % (m["width"], m["height"], m["refreshRate"])
            break
except Exception:
    pass

# ws5 is the TV workspace (see the workspace rule in hyprland.lua).
on_tv = [c for c in clients if c.get("workspace", {}).get("id") == 5]
game = next((c for c in on_tv if re.match(r"^steam_app_", c.get("class") or "")
             or (c.get("class") or "") == "gamescope"), None)
big = next((c for c in on_tv
            if re.search(r"big picture", c.get("title") or "", re.I)), None)

suffix = " (%s)" % mode if mode else ""
if game:
    title = (game.get("title") or game.get("class") or "game").strip()
    out = {"text": "%s" % title[:22], "class": "gaming",
           "tooltip": "Playing on TV%s — click to turn off" % suffix}
elif big:
    out = {"text": "Big Picture", "class": "bigpicture",
           "tooltip": "Steam Big Picture on TV%s — click to turn off" % suffix}
else:
    out = {"text": "TV", "class": "idle",
           "tooltip": "TV on%s, idle — click to turn off" % suffix}

print(json.dumps(out))
'
