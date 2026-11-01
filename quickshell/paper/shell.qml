//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "modules"
import "services"

ShellRoot {
    Variants { model: Quickshell.screens; Wallpaper {} }
    Variants { model: Quickshell.screens; WindowFrames {} }
    Variants { model: Quickshell.screens; Reserve {} }
    Variants { model: Quickshell.screens; Widgets {} }
    Variants { model: Quickshell.screens; TopBar {} }
    Variants { model: Quickshell.screens; Dock {} }
    Variants { model: Quickshell.screens; Launcher {} }
    Variants { model: Quickshell.screens; Session {} }
    Variants { model: Quickshell.screens; ControlCenter {} }
    Variants { model: Quickshell.screens; NotifCenter {} }
    Variants { model: Quickshell.screens; Clipboard {} }
    Variants { model: Quickshell.screens; Emoji {} }
    Variants { model: Quickshell.screens; Cheatsheet {} }
    Variants { model: Quickshell.screens; WallpaperPicker {} }
    Variants { model: Quickshell.screens; Notes {} }
    Variants { model: Quickshell.screens; Crosshair {} }
    Variants { model: Quickshell.screens; PolkitDialog {} }

    Binding {
        target: Quickshell
        property: "watchFiles"
        value: !Lock.locked
    }

    Notifications {}
    Osd {}
    Files {}
    Settings {}
    LockScreen {}

    GlobalShortcut {
        name: "launcherToggle"
        description: "Launcher"
        onReleased: GlobalState.launcherOpen = !GlobalState.launcherOpen
    }

    GlobalShortcut {
        name: "clipboardToggle"
        description: "Clipboard"
        onPressed: GlobalState.clipboardOpen = !GlobalState.clipboardOpen
    }

    GlobalShortcut {
        name: "sessionToggle"
        description: "Session menu"
        onPressed: GlobalState.sessionOpen = !GlobalState.sessionOpen
    }

    GlobalShortcut {
        name: "gameBarToggle"
        description: "Game mode"
        onPressed: Sys.setGame(!Sys.game)
    }

    GlobalShortcut {
        name: "brightnessUp"
        description: "Brighter"
        onPressed: Sys.nudgeBrightness(0.05)
    }

    GlobalShortcut {
        name: "brightnessDown"
        description: "Dimmer"
        onPressed: Sys.nudgeBrightness(-0.05)
    }

    GlobalShortcut {
        name: "kbdBrightnessUp"
        description: "Keyboard light up"
        onPressed: Quickshell.execDetached(["sh", "-c", "brightnessctl -q -d '*kbd_backlight*' set 25%+"])
    }

    GlobalShortcut {
        name: "kbdBrightnessDown"
        description: "Keyboard light down"
        onPressed: Quickshell.execDetached(["sh", "-c", "brightnessctl -q -d '*kbd_backlight*' set 25%-"])
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { GlobalState.launcherOpen = !GlobalState.launcherOpen; }
        function open(): void { GlobalState.launcherOpen = true; }
        function hide(): void { GlobalState.launcherOpen = false; }
    }

    IpcHandler {
        target: "apps"
        function toggle(): void { GlobalState.launcherOpen = !GlobalState.launcherOpen; }
    }

    IpcHandler {
        target: "session"
        function toggle(): void { GlobalState.sessionOpen = !GlobalState.sessionOpen; }
        function open(): void { GlobalState.sessionOpen = true; }
        function hide(): void { GlobalState.sessionOpen = false; }
    }

    IpcHandler {
        target: "nothing"
        function toggle(): void { GlobalState.controlOpen = !GlobalState.controlOpen; }
    }

    IpcHandler {
        target: "control"
        function toggle(): void { GlobalState.controlOpen = !GlobalState.controlOpen; }
    }

    IpcHandler {
        target: "files"
        function toggle(): void { GlobalState.filesOpen = !GlobalState.filesOpen; }
        function open(): void { GlobalState.filesOpen = true; }
        function openPath(path: string): void { GlobalState.openFiles(path); }
        function hide(): void { GlobalState.filesOpen = false; }
    }

    IpcHandler {
        target: "settings"
        function toggle(): void { GlobalState.toggleSettings(""); }
        function open(page: string): void { GlobalState.openSettings(page); }
        function processes(): void { GlobalState.openSettings("processes"); }
    }

    IpcHandler {
        target: "displays"
        function toggle(): void { GlobalState.toggleSettings("screen"); }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void { GlobalState.notifOpen = !GlobalState.notifOpen; }
        function quiet(): void { Config.set("dnd", !Config.dnd); }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { GlobalState.clipboardOpen = !GlobalState.clipboardOpen; }
    }

    IpcHandler {
        target: "emoji"
        function toggle(): void { GlobalState.emojiOpen = !GlobalState.emojiOpen; }
    }

    IpcHandler {
        target: "cheatsheet"
        function toggle(): void { GlobalState.cheatsheetOpen = !GlobalState.cheatsheetOpen; }
    }

    IpcHandler {
        target: "essential"
        function toggle(): void { GlobalState.notesOpen = !GlobalState.notesOpen; }
    }

    IpcHandler {
        target: "bar"
        function toggle(): void { Config.set("showBar", !Config.showBar); }
    }

    IpcHandler {
        target: "wallpaper"
        function next(): void { Wall.next(); }
        function set(path: string): void { Wall.set(path); }
    }

    IpcHandler {
        target: "wallpaperpicker"
        function toggle(): void { GlobalState.wallpaperOpen = !GlobalState.wallpaperOpen; }
    }

    IpcHandler {
        target: "nightlight"
        function toggle(): void { Sys.setNight(!Sys.night); }
    }

    IpcHandler {
        target: "caffeine"
        function toggle(): void { Sys.setCaffeine(!Sys.caffeine); }
    }

    IpcHandler {
        target: "game"
        function toggle(): void { Sys.setGame(!Sys.game); }
        function mode(): void { Sys.setGame(!Sys.game); }
        function crosshair(): void { Sys.crosshair = !Sys.crosshair; }
    }

    IpcHandler {
        target: "brightness"
        function up(): void { Sys.nudgeBrightness(0.05); }
        function down(): void { Sys.nudgeBrightness(-0.05); }
    }

    IpcHandler {
        target: "screenshot"
        function region(): void { Sys.screenshot("region", "copy"); }
        function window(): void { Sys.screenshot("window", "copy"); }
        function screen(): void { Sys.screenshot("screen", "copy"); }
        function save(): void { Sys.screenshot("screen", "save"); }
        function ocr(): void { Sys.screenshot("region", "ocr"); }
    }

    IpcHandler {
        target: "record"
        function toggle(): void { Sys.record("screen", "none"); }
        function region(): void { Sys.record("region", "none"); }
        function sound(): void { Sys.record("screen", "sys"); }
    }

    IpcHandler {
        target: "lens"
        function search(): void { Sys.lens(); }
    }

    IpcHandler {
        target: "song"
        function toggle(): void { Sys.song(); }
    }

    IpcHandler {
        target: "lock"
        function activate(): string {
            Lock.activate();
            return "ok";
        }
    }

    IpcHandler {
        target: "shell"
        function reload(): void {
            if (!Lock.locked)
                Quickshell.reload(true);
        }
    }
}
