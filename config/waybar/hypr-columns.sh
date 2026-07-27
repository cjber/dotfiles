#!/usr/bin/env bash
# Waybar module: scrolling-layout column indicator.
#
# The scrolling layout has no built-in way to see columns that have scrolled
# off the viewport -- confirmed against the 0.56 wiki, there is no indicator,
# overview or peek dispatcher. This renders the whole tape as text so the
# off-screen columns are always visible at a glance.
#
# Visible columns render in normal text, the focused one in the accent colour,
# and columns scrolled off either edge render dimmed with a `2<` / `>1` count.
# Terminal windows show their title (usually the running command); everything
# else shows its class. For a terminal-driven setup this beats a thumbnail
# grid, where every window is the same dark rectangle.
#
# Runs persistently and reprints on Hyprland IPC events rather than polling,
# so it costs no idle CPU.

set -uo pipefail

ACCENT="#e78a53" # primary - focused column
TEXT="#c1c1c1"   # text    - visible columns
DIM="#4a4a4a"    # dimmed  - scrolled off-screen
MAXLEN=14        # truncate each label to this many chars

RT="${XDG_RUNTIME_DIR:-/tmp}"
CDIR="$RT/hypr-columns.$$"
mkdir -p "$CDIR"
trap 'rm -rf "$CDIR"' EXIT

LAST=""

render() {
    hyprctl -j clients >"$CDIR/c" 2>/dev/null || return
    hyprctl -j monitors >"$CDIR/m" 2>/dev/null || return
    hyprctl -j activewindow >"$CDIR/a" 2>/dev/null || echo '{}' >"$CDIR/a"

    local out
    out=$(python3 - "$ACCENT" "$TEXT" "$DIM" "$MAXLEN" "$CDIR" <<'PY'
import json, sys, html

accent, text_c, dim_c, maxlen, cdir = (
    sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4]), sys.argv[5]
)

def load(name):
    try:
        with open("%s/%s" % (cdir, name)) as f:
            return json.load(f)
    except Exception:
        return None

clients = load('c') or []
monitors = load('m') or []
active = load('a') or {}

mon = next((m for m in monitors if m.get('focused')), None)
if not mon:
    print(json.dumps({'text': ''}), flush=True)
    raise SystemExit

ws_id = mon.get('activeWorkspace', {}).get('id')
mon_x0 = mon.get('x', 0)
mon_x1 = mon_x0 + mon.get('width', 0)
mon_y0 = mon.get('y', 0)
mon_y1 = mon_y0 + mon.get('height', 0)
# A 90/270-rotated monitor reports width/height pre-rotation, so swap them to
# get the on-screen extent. Matters for DP-2, which scrolls vertically.
if mon.get('transform', 0) in (1, 3, 5, 7):
    mon_x1 = mon_x0 + mon.get('height', 0)
    mon_y1 = mon_y0 + mon.get('width', 0)
vertical = mon.get('transform', 0) in (1, 3, 5, 7)

wins = [c for c in clients
        if c.get('workspace', {}).get('id') == ws_id
        and not c.get('floating')
        and c.get('mapped', True)]

if not wins:
    print(json.dumps({'text': '', 'tooltip': 'no tiled windows'}), flush=True)
    raise SystemExit

# Group windows into columns by position along the scroll axis. The scrolling
# layout can stack several windows in one column (via `consume`); they share a
# coordinate on that axis.
axis = 1 if vertical else 0
cols = {}
for w in wins:
    cols.setdefault(round(w['at'][axis] / 10) * 10, []).append(w)

active_addr = active.get('address')

def label(col):
    # Prefer the title for terminals: it carries the running command, the only
    # thing distinguishing one dark rectangle from another.
    w = col[0]
    for c in col:
        if c.get('address') == active_addr:
            w = c
            break
    cls = (w.get('class') or '?').lower()
    if cls in ('kitty', 'foot', 'alacritty', 'wezterm', 'ghostty'):
        s = w.get('title') or cls
    else:
        s = cls.replace('google-', '').replace('-stable', '')
    # Strip leading spinner glyphs (braille U+2800-28FF and the common ASCII
    # set). TUIs animate these every frame, which would otherwise churn the
    # bar several times a second.
    s = s.lstrip()
    while s and (0x2800 <= ord(s[0]) <= 0x28FF or s[0] in '|/-\\*+.<>'):
        s = s[1:].lstrip()
    s = s.strip() or cls
    if len(s) > maxlen:
        s = s[: maxlen - 1] + '…'
    if len(col) > 1:
        s += '+%d' % (len(col) - 1)
    return s

lo, hi = (mon_y0, mon_y1) if vertical else (mon_x0, mon_x1)

parts, off_before, off_after = [], 0, 0
for key in sorted(cols):
    col = cols[key]
    w = col[0]
    p0 = w['at'][axis]
    p1 = p0 + w['size'][axis]
    # Off-screen only if substantially outside, so a few pixels of border
    # overhang doesn't read as hidden.
    visible = (p1 - lo) > 40 and (hi - p0) > 40
    focused = any(c.get('address') == active_addr for c in col)
    txt = html.escape(label(col))
    if focused:
        parts.append("<span color='%s'><b>%s</b></span>" % (accent, txt))
    elif visible:
        parts.append("<span color='%s'>%s</span>" % (text_c, txt))
    else:
        parts.append("<span color='%s'>%s</span>" % (dim_c, txt))
        if p1 <= lo:
            off_before += 1
        else:
            off_after += 1

body = ("<span color='%s'> · </span>" % dim_c).join(parts)
if off_before:
    body = "<span color='%s'>%d‹ </span>" % (dim_c, off_before) + body
if off_after:
    body += "<span color='%s'> ›%d</span>" % (dim_c, off_after)

hidden = off_before + off_after
tip = '%d column%s, %d off-screen' % (
    len(cols), '' if len(cols) == 1 else 's', hidden)
print(json.dumps({
    'text': body,
    'tooltip': tip,
    'class': 'has-hidden' if hidden else 'all-visible',
}), flush=True)
PY
    )
    # Only emit on change; TUI titles update far more often than the column
    # set does, and waybar redraws on every line it receives.
    [[ "$out" == "$LAST" ]] && return
    LAST="$out"
    printf '%s\n' "$out"
}

render

SOCK="$RT/hypr/${HYPRLAND_INSTANCE_SIGNATURE:-}/.socket2.sock"
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" && -S "$SOCK" ]] && command -v socat >/dev/null; then
    # Reprint on events that change the column set or the viewport offset.
    socat -u UNIX-CONNECT:"$SOCK" - 2>/dev/null | while read -r line; do
        case "$line" in
        openwindow* | closewindow* | movewindow* | activewindow* | \
            workspace* | focusedmon* | changefloatingmode* | fullscreen*)
            render
            ;;
        esac
    done
else
    # Fallback: no IPC socket (or no socat) -- poll slowly.
    while sleep 2; do render; done
fi
