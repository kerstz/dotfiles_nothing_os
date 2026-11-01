pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string dir: `${Quickshell.env("HOME")}/.config/paper`
    property bool ready: false

    property alias scale: a.scale
    property alias localeName: a.localeName
    property alias quote: a.quote
    property alias photo: a.photo
    property alias photoCaption: a.photoCaption
    property alias wallpaper: a.wallpaper
    property alias idleTitle: a.idleTitle
    property alias idleArtist: a.idleArtist
    property alias idleCover: a.idleCover
    property alias todos: a.todos
    property alias notes: a.notes
    property alias clock24: a.clock24
    property alias wallpaperFolder: a.wallpaperFolder
    property alias showClock: a.showClock
    property alias showQuote: a.showQuote
    property alias showTodo: a.showTodo
    property alias showMusic: a.showMusic
    property alias showPhoto: a.showPhoto
    property alias showDoodles: a.showDoodles
    property alias showTray: a.showTray
    property alias showBattery: a.showBattery
    property alias showBar: a.showBar
    property alias showDock: a.showDock
    property alias pinned: a.pinned
    property alias dnd: a.dnd
    property alias nightKelvin: a.nightKelvin
    property alias crosshairColor: a.crosshairColor
    property alias crosshairSize: a.crosshairSize
    property alias idleDim: a.idleDim
    property alias idleLock: a.idleLock
    property alias idleOff: a.idleOff
    property alias idleSuspend: a.idleSuspend
    property alias layoutName: a.layoutName
    property alias animations: a.animations
    property alias kbLayout: a.kbLayout
    property alias kbVariant: a.kbVariant
    property alias sensitivity: a.sensitivity
    property alias naturalScroll: a.naturalScroll
    property alias touchNatural: a.touchNatural
    property alias touchTap: a.touchTap

    readonly property var locale: Qt.locale(a.localeName)

    readonly property string apps: `${Quickshell.shellDir}/apps`
    readonly property string trash: `${Quickshell.env("HOME")}/.local/share/Trash/files`

    readonly property var dockApps: {
        const base = root.dock;
        const extra = [];
        const list = a.pinned ?? [];
        for (let i = 0; i < list.length; i++) {
            const e = DesktopEntries.byId(String(list[i]));
            if (e)
                extra.push({ id: String(list[i]), iconPath: Quickshell.iconPath(e.icon ?? "", true), label: e.name, cls: e.startupClass ?? "", entry: e });
        }
        const at = base.findIndex(b => b.separator === true);
        return base.slice(0, at).concat(extra).concat(base.slice(at));
    }

    readonly property var dock: [
        { id: "terminal", icon: "terminal", label: "Terminal", cls: "kitty", cmd: `${root.apps}/paper-term.sh` },
        { id: "files", icon: "folder_open", label: "Files", cls: "org.quickshell", action: "files" },
        { id: "browser", icon: "globe", label: "Firefox", cls: "paper-firefox", cmd: `${root.apps}/paper-firefox.sh` },
        { id: "code", icon: "vscode", label: "VS Code", cls: "code", cmd: "command -v code >/dev/null && exec code; command -v codium >/dev/null && exec codium; command -v zed >/dev/null && exec zed; exec kate" },
        { id: "spotify", icon: "spotify", label: "Spotify", cls: "spotify", cmd: `command -v spotify >/dev/null && exec spotify; exec ${root.apps}/paper-firefox.sh https://open.spotify.com` },
        { id: "images", icon: "image", label: "Images", cls: "org.kde.gwenview", cmd: "command -v gwenview >/dev/null && exec gwenview; exec xdg-open \"$HOME\"" },
        { id: "settings", icon: "gear", label: "Settings", cls: "systemsettings", cmd: "exec systemsettings" },
        { id: "sep", separator: true },
        { id: "trash", icon: "trash", label: "Trash", action: "trash" }
    ]

    function saveSoon(): void {
        if (root.ready)
            persist.restart();
    }

    function setTodos(list: var): void {
        a.todos = list;
        root.saveSoon();
    }

    function setNotes(list: var): void {
        a.notes = list;
        root.saveSoon();
    }

    function set(key: string, value: var): void {
        a[key] = value;
        root.saveSoon();
    }

    Process {
        running: true
        command: ["mkdir", "-p", root.dir]
    }

    Timer {
        id: persist
        interval: 120
        onTriggered: file.writeAdapter()
    }

    FileView {
        id: file
        path: `${root.dir}/config.json`
        watchChanges: true
        preload: true
        blockLoading: true
        onFileChanged: reload()
        onLoaded: root.ready = true
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                root.ready = true;
                writeAdapter();
            }
        }

        adapter: JsonAdapter {
            id: a
            property real scale: 1.0
            property string localeName: "en_GB"
            property string quote: "“A little progress\nevery day...\nadds up to\nbig results."
            property string photo: ""
            property string photoCaption: "Same\nSky\nDifferent\nDay..."
            property string wallpaper: ""
            property string idleTitle: "Again"
            property string idleArtist: "YUI"
            property string idleCover: ""
            property bool clock24: false
            property string wallpaperFolder: ""
            property bool showClock: true
            property bool showQuote: true
            property bool showTodo: true
            property bool showMusic: true
            property bool showPhoto: true
            property bool showDoodles: true
            property bool showTray: true
            property bool showBattery: true
            property bool showBar: true
            property bool showDock: true
            property var pinned: []
            property bool dnd: false
            property int nightKelvin: 4200
            property string crosshairColor: "#e27268"
            property real crosshairSize: 14
            property int idleDim: 120
            property int idleLock: 300
            property int idleOff: 330
            property int idleSuspend: 1800
            property string layoutName: "lua:paper"
            property bool animations: true
            property string kbLayout: ""
            property string kbVariant: ""
            property real sensitivity: 0
            property bool naturalScroll: false
            property bool touchNatural: true
            property bool touchTap: true
            property var notes: [
                { text: "Things to Remember:\n- Stay Consistent\n- Keep Learning\n- Build Cool Stuff\n- Be Kind :)" }
            ]
            property var todos: [
                { text: "Study MCIT", done: false },
                { text: "Rust crash course", done: true },
                { text: "Work on project", done: false },
                { text: "Workout", done: false },
                { text: "Read something new", done: false }
            ]
        }
    }
}
