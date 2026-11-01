pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property var all: Hyprland.toplevels?.values ?? []
    property bool fast: false
    property string activeSpecial: ""

    function classOf(t: var): string {
        return String(t?.lastIpcObject?.class ?? "");
    }

    function addressOf(t: var): string {
        return String(t?.lastIpcObject?.address ?? "");
    }

    function workspaceNameOf(t: var): string {
        return String(t?.lastIpcObject?.workspace?.name ?? "");
    }

    function kick(): void {
        root.fast = true;
        slowDown.restart();
    }

    function focus(addr: string): void {
        if (addr !== "")
            Hyprland.dispatch(`hl.dsp.focus({ window = "address:${addr}" })`);
    }

    function close(addr: string): void {
        if (addr !== "")
            Hyprland.dispatch(`hl.dsp.window.close({ window = "address:${addr}" })`);
    }

    function minimise(addr: string): void {
        if (addr !== "")
            Hyprland.dispatch(`hl.dsp.window.move({ window = "address:${addr}", workspace = "special:min", follow = false })`);
    }

    function maximise(addr: string): void {
        if (addr === "")
            return;
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:${addr}" })`);
        Hyprland.dispatch(`hl.dsp.window.fullscreen({ mode = "maximized" })`);
    }

    function restore(t: var): void {
        const addr = root.addressOf(t);
        if (addr === "")
            return;
        if (root.workspaceNameOf(t) === "special:min") {
            const ws = Hyprland.focusedWorkspace?.id ?? 1;
            Hyprland.dispatch(`hl.dsp.window.move({ window = "address:${addr}", workspace = "${ws}", follow = true })`);
        }
        root.focus(addr);
    }

    function find(cls: string): var {
        const needle = cls.toLowerCase();
        const list = root.all;
        for (let i = 0; i < list.length; i++) {
            if (root.classOf(list[i]).toLowerCase() === needle)
                return list[i];
        }
        return null;
    }

    function label(cls: string): string {
        const known = {
            "kitty": "Terminal",
            "org.quickshell": "Files",
            "paper-firefox": "Firefox",
            "firefox": "Firefox",
            "code": "VS Code",
            "org.kde.dolphin": "Dolphin",
            "org.kde.gwenview": "Gwenview",
            "systemsettings": "Settings"
        };
        if (known[cls] !== undefined)
            return known[cls];
        const tail = cls.split(".").pop();
        return tail.length ? tail.charAt(0).toUpperCase() + tail.slice(1) : "";
    }

    Timer {
        id: slowDown
        interval: 700
        onTriggered: root.fast = false
    }

    Timer {
        interval: root.fast ? 33 : 160
        running: true
        repeat: true
        onTriggered: Hyprland.refreshToplevels()
    }

    Connections {
        target: Hyprland
        function onRawEvent(e: var): void {
            const n = e.name;
            if (n === "activespecial") {
                root.activeSpecial = String(e.data).split(",")[0];
            }
            if (n.startsWith("openwindow") || n.startsWith("closewindow") || n.startsWith("movewindow")
                || n.startsWith("workspace") || n.startsWith("fullscreen") || n.startsWith("changefloatingmode")
                || n.startsWith("activespecial") || n.startsWith("activewindow") || n.startsWith("windowtitle"))
                root.kick();
        }
    }

    Component.onCompleted: Hyprland.refreshToplevels()
}
