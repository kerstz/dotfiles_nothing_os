//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "modules"

ShellRoot {
    id: root

    Variants { model: Quickshell.screens; Wallpaper {} }
    Variants { model: Quickshell.screens; Taskbar {} }
    Variants { model: Quickshell.screens; StartMenu {} }
    Variants { model: Config.crt ? Quickshell.screens : []; CrtOverlay {} }

    GlobalShortcut {
        name: "launcherToggle"
        description: "Start menu (tap and release SUPER)"
        onReleased: GlobalState.toggleStart()
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { GlobalState.toggleStart(); }
        function open(): void { GlobalState.startOpen = true; }
        function hide(): void { GlobalState.startOpen = false; }
    }

    IpcHandler {
        target: "start"
        function toggle(): void { GlobalState.toggleStart(); }
        function open(): void { GlobalState.startOpen = true; }
        function hide(): void { GlobalState.startOpen = false; }
    }

    // SUPER+ALT+L and the session keys land on the start menu, which is
    // where this rice keeps its power controls.
    IpcHandler {
        target: "nothing"
        function toggle(): void { GlobalState.toggleStart(); }
    }

    IpcHandler {
        target: "session"
        function toggle(): void { GlobalState.toggleStart(); }
        function open(): void { GlobalState.startOpen = true; }
        function hide(): void { GlobalState.startOpen = false; }
    }

    IpcHandler {
        target: "crt"
        function toggle(): void { Config.crt = !Config.crt; }
        function flicker(): void { Config.crtFlicker = !Config.crtFlicker; }
    }
}
