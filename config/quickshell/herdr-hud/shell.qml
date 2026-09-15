// Standalone Quickshell host for the Herdr HUD panel.
//
// Upstream ships HerdrHud.qml as an omarchy-shell plugin: the host instantiates
// it and injects `shell` + `manifest`. Neither is required here --
//   * `shell` is only used by requestClose(), which already falls back to close()
//     when it is null, and
//   * `manifest` only feeds pluginId/pluginDir, and pluginDir is never read.
// The panel creates its own per-screen WlrLayer.Overlay PanelWindows, so it needs
// no surface from the host either. This file therefore only supplies the plugin
// identity and an IPC entry point for Hyprland keybinds.
import Quickshell
import Quickshell.Io

ShellRoot {
  HerdrHud {
    id: hud
    manifest: ({ id: "finna.herdr-hud", __sourceDir: Qt.resolvedUrl(".") })
  }

  // Reached from Hyprland binds via `qs -c herdr-hud ipc call hud <fn>`.
  IpcHandler {
    target: "hud"

    // Open/close the agent panel, leaving the H bubble on screen.
    function toggle(): void {
      if (hud.opened) hud.requestClose()
      else hud.open("{}")
    }

    // Show or hide the entire HUD, H bubble included.
    function toggleVisibility(): void { hud.toggleVisibility("{}") }

    function show(): void { hud.open("{}") }
    function hide(): void { hud.requestClose() }
  }
}
