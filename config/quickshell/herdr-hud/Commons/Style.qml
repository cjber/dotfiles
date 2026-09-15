// Stand-in for Omarchy Quattro's `qs.Commons` Style singleton.
// HerdrHud.qml uses exactly one thing from it: Style.font.family (16 call sites),
// so this is the whole compatibility surface. Nothing else from Commons is
// referenced, which is why the upstream plugin runs unmodified on vanilla Hyprland.
pragma Singleton

import QtQuick
import Quickshell

Singleton {
  readonly property QtObject font: QtObject {
    readonly property string family: "JetBrainsMono Nerd Font"
  }
}
