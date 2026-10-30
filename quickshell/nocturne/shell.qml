//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import Quickshell.Io
import "components"
import "modules"
import "services"

// Nocturne: a Windows-like shell over Hyprland. A bottom taskbar with a
// start orb, running-window buttons, tray and clock; a start menu; a power
// dialog and a calendar flyout. Cold violet throughout.
ShellRoot {
    id: root

    Component.onCompleted: void Windows.toplevels

    Variants {
        model: Config.drawWallpaper ? Quickshell.screens : []
        Background {}
    }

    Variants {
        model: Quickshell.screens
        Taskbar {}
    }

    // Overlays: one instance each, on the focused output.
    StartMenu {}
    PowerMenu {}
    CalendarFlyout {}

    // Tap-and-release of SUPER alone opens the start menu (bound on the
    // Hyprland side as quickshell:launcherToggle).
    GlobalShortcut {
        name: "launcherToggle"
        description: "Start menu (tap and release SUPER)"
        onReleased: GlobalState.toggleStart()
    }

    GlobalShortcut {
        name: "sessionToggle"
        description: "Power menu"
        onPressed: GlobalState.togglePower()
    }

    // The shared keybinds call these ipc targets; nocturne maps them onto
    // its own surfaces so SUPER+R, SUPER+Tab and SUPER+Escape just work.
    IpcHandler {
        target: "launcher"
        function toggle(): void { GlobalState.toggleStart(); }
        function open(): void { GlobalState.closeAll(); GlobalState.startOpen = true; }
        function hide(): void { GlobalState.startOpen = false; }
    }

    IpcHandler {
        target: "start"
        function toggle(): void { GlobalState.toggleStart(); }
        function open(): void { GlobalState.closeAll(); GlobalState.startOpen = true; }
        function hide(): void { GlobalState.startOpen = false; }
    }

    IpcHandler {
        target: "session"
        function toggle(): void { GlobalState.togglePower(); }
        function open(): void { GlobalState.closeAll(); GlobalState.powerOpen = true; }
        function hide(): void { GlobalState.powerOpen = false; }
    }

    IpcHandler {
        target: "calendar"
        function toggle(): void { GlobalState.toggleCalendar(0); }
    }

    IpcHandler {
        target: "shell"
        function reload(): void { Quickshell.reload(true); }
        function reloadAll(): void {
            Quickshell.execDetached(["hyprctl", "reload"]);
            Quickshell.reload(true);
        }
    }
}
