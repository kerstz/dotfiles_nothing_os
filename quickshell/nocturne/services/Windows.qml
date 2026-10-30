pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// The running windows, as the taskbar sees them, plus focus/close/minimise
// helpers. Hyprland's toplevel model is kept fresh on the events that move
// windows around.
Singleton {
    id: root

    readonly property var toplevels: {
        Hyprland.toplevels?.values;
        return (Hyprland.toplevels?.values ?? []).filter(t => {
            const ipc = t.lastIpcObject ?? {};
            if (!t.workspace && !ipc.workspace) return false;
            if (ipc.hidden) return false;
            return true;
        });
    }

    // Tracked from activewindowv2 (its payload is the window address),
    // normalised to the 0x-prefixed form lastIpcObject.address carries.
    property string activeAddress: ""

    function addressOf(t: var): string {
        return String(t?.lastIpcObject?.address ?? "");
    }
    function classOf(t: var): string {
        return String(t?.lastIpcObject?.class ?? t?.lastIpcObject?.initialClass ?? "");
    }
    function titleOf(t: var): string {
        return String(t?.title ?? t?.lastIpcObject?.title ?? "");
    }

    function focus(addr: string): void {
        if (!addr) return;
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:${addr}" })`);
    }
    function close(addr: string): void {
        if (!addr) return;
        Hyprland.dispatch(`hl.dsp.window.close({ window = "address:${addr}" })`);
    }
    // Click the active window's button to tuck it onto the special
    // workspace, the nearest thing to "minimise" under a tiling compositor.
    function minimise(addr: string): void {
        if (!addr) return;
        Hyprland.dispatch(
            `hl.dsp.window.move({ window = "address:${addr}", workspace = "special:min", follow = false })`);
    }
    function restoreMinimised(): void {
        Hyprland.dispatch(`hl.dsp.workspace.toggle_special("min")`);
    }
    // Pull one window back from special:min onto the current workspace.
    function restore(addr: string): void {
        if (!addr) return;
        Hyprland.dispatch(
            `hl.dsp.window.move({ window = "address:${addr}", workspace = "e+0", follow = true })`);
    }

    Timer {
        id: refresh
        interval: 70
        onTriggered: Hyprland.refreshToplevels()
    }

    Connections {
        target: Hyprland
        function onRawEvent(event: var): void {
            const n = event.name;
            if (n === "activewindowv2") {
                const d = String(event.data ?? "").trim();
                root.activeAddress = d === "" || d === "," ? "" : "0x" + d.replace(/^0x/, "");
            }
            if (n === "openwindow" || n === "closewindow"
                || n === "movewindow" || n === "movewindowv2"
                || n === "activewindow" || n === "activewindowv2"
                || n === "windowtitle" || n === "windowtitlev2"
                || n === "workspace" || n === "workspacev2"
                || n === "fullscreen")
                refresh.restart();
        }
    }

    Component.onCompleted: Hyprland.refreshToplevels()
}
