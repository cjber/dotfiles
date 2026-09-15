# Herdr HUD on vanilla Hyprland

Upstream ships this as an **Omarchy Quattro** plugin
(<https://github.com/finna/omarchy-herdr-hud>), which needs `omarchy-shell`.
This machine runs plain Arch + Hyprland 0.56.2, so the plugin is hosted directly
on [Quickshell](https://quickshell.org) instead. Upstream's own files are copied
here **unmodified**; everything Omarchy-specific is replaced by two small shims.

## Why this works at all

The panel turned out to need almost nothing from its host:

| Upstream dependency | Used for | Replacement |
| --- | --- | --- |
| `qs.Commons` → `Style.font.family` | 16 font references | `Commons/Style.qml` |
| `qs.Commons` → `Color.{foreground,background,accent,urgent}` | 4 theme colours | `Commons/Color.qml` |
| injected `shell` object | `requestClose()` only | nothing — it already falls back to `close()` when null |
| injected `manifest` | `pluginId`; `pluginDir` is never read | literal in `shell.qml` |
| host-provided surface | — | none needed: `HerdrHud.qml` creates its own per-screen `WlrLayer.Overlay` `PanelWindow`s |

That last row is the important one. The panel is self-hosting, so it runs on any
wlroots compositor; `omarchy-shell` was only ever a loader.

`Color.qml` tracks the "Oxide" palette from `~/.config/hypr/hyprland.lua` so the
HUD matches the desktop. Edit that file to re-theme.

## Files

- `shell.qml` — Quickshell entry point; instantiates the panel and exposes IPC.
- `Commons/Style.qml`, `Commons/Color.qml` — the shims above.
- `HerdrHud.qml`, `Roster.js`, `Alerts.js`, `bin/herdr-hud`, `manifest.json` —
  upstream, unmodified. `.upstream-commit` records which revision.

## Use

Driven by `~/scripts/herdr-hud` (`start`/`toggle`/`visibility`/`stop`/`status`),
which `hyprland.lua` binds and autostarts:

- `SUPER+CTRL+H` — open/close the agent panel
- `SUPER+CTRL+SHIFT+H` — show/hide the whole HUD

Upstream suggests `SUPER+H` / `SUPER+SHIFT+H`; both are already bound here to
scrolling focus/move, hence `CTRL`.

Game mode (`keyboard-mode.sh`, Zerosprey42 F24) also calls `herdr-hud start`.

## Updating

```sh
git clone --depth 1 https://github.com/finna/omarchy-herdr-hud /tmp/hh
cp /tmp/hh/{HerdrHud.qml,Roster.js,Alerts.js,manifest.json} .
cp /tmp/hh/bin/herdr-hud bin/herdr-hud
git -C /tmp/hh rev-parse HEAD > .upstream-commit
```

Then restart (`herdr-hud stop && herdr-hud start`) and check the log for
`ReferenceError: <Name> is not defined` — that is how a newly-referenced
`qs.Commons` symbol shows up, and it means adding a property to the shims.

## Requirements

`quickshell` (extra), `herdr` >= 0.9.0, Python 3 for the bridge.
