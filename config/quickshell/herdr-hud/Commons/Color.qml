// Stand-in for Omarchy Quattro's `qs.Commons` Color singleton.
// HerdrHud.qml reads exactly four properties from it; every other colour in the
// panel is a literal in the plugin itself. Values track the "Oxide" palette in
// ~/.config/hypr/hyprland.lua so the HUD matches the rest of the desktop.
pragma Singleton

import QtQuick
import Quickshell

Singleton {
  readonly property color background: "#121113"  // Oxide base
  readonly property color foreground: "#c1c1c1"  // Oxide text
  readonly property color accent:     "#e78a53"  // Oxide primary
  readonly property color urgent:     "#e35d5d"  // attention badge
}
