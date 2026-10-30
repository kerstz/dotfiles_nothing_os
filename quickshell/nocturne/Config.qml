pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Persisted in ~/.config/nocturne/config.json. Kept deliberately small:
// nocturne is a focused rice, not nothing's full control surface.
Singleton {
    id: root

    readonly property string dir: `${Quickshell.env("HOME")}/.config/nocturne`
    readonly property string path: `${root.dir}/config.json`
    property bool ready: false

    property alias scale: a.scale
    property alias accent: a.accent
    property alias drawWallpaper: a.drawWallpaper
    property alias wallpaper: a.wallpaper
    property alias terminal: a.terminal
    property alias taskbarApps: a.taskbarApps
    property alias pinned: a.pinned
    property alias showSeconds: a.showSeconds
    property alias twentyFourHour: a.twentyFourHour

    function pinnedList(): var {
        const v = a.pinned;
        if (!v || v.length === undefined) return [];
        const out = [];
        for (let i = 0; i < v.length; i++) out.push(v[i]);
        return out;
    }

    function isPinned(id: string): bool { return root.pinnedList().indexOf(id) >= 0; }

    function togglePinned(id: string): void {
        const list = root.pinnedList();
        const at = list.indexOf(id);
        if (at >= 0) list.splice(at, 1);
        else list.push(id);
        a.pinned = list;
        root.save();
    }

    function save(): void {
        if (!root.ready) return;
        persist.restart();
    }

    Process {
        id: mkdir
        running: true
        command: ["mkdir", "-p", root.dir]
    }

    Timer {
        id: persist
        interval: 80
        onTriggered: if (root.ready) file.writeAdapter()
    }

    FileView {
        id: file
        path: root.path
        watchChanges: true
        preload: true
        blockLoading: true
        onFileChanged: reload()
        onAdapterUpdated: if (root.ready) persist.restart()
        onLoaded: root.ready = true
        onLoadFailed: (err) => {
            if (err === FileViewError.FileNotFound) {
                root.ready = true;
                writeAdapter();
            }
        }

        adapter: JsonAdapter {
            id: a
            property real   scale: 1.0
            property string accent: "#b69cff"
            property bool   drawWallpaper: true
            // "" = the shipped hypr/wallpapers/nocturne.png, else a path.
            property string wallpaper: ""
            property string terminal: "foot"
            property bool   showSeconds: false
            property bool   twentyFourHour: true
            // .desktop ids pinned to the taskbar's launcher row.
            property var    pinned: ["foot", "firefox", "org.kde.dolphin"]
            property var    taskbarApps: []
        }
    }
}
