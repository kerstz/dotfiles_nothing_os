import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import ".."
import "../components"

Scope {
    id: scope

    LazyLoader {
        active: GlobalState.filesOpen

        FloatingWindow {
            id: win

            readonly property string home: Quickshell.env("HOME")
            readonly property real u: Math.max(0.8, (Hyprland.focusedMonitor?.height ?? 1080) / 720) * Config.scale
            property string path: GlobalState.filesPath !== "" ? GlobalState.filesPath : home
            property var backStack: []
            property var forwardStack: []
            property string query: ""
            property bool searching: false
            property bool showHidden: false
            property bool reversed: false
            property bool menuOpen: false
            property var xdg: ({})
            property var items: []
            property int selected: -1

            title: `Files - ${win.titleName}`
            color: "transparent"
            implicitWidth: Math.round(377 * u)
            implicitHeight: Math.round(344 * u)

            onClosed: GlobalState.filesOpen = false

            readonly property string titleName: win.path === win.home ? "Home" : win.path === Config.trash ? "Trash" : win.path.split("/").pop()

            readonly property var places: [
                { label: "Home", icon: "home", path: win.home },
                { label: "Desktop", icon: "desktop", path: win.xdgPath("DESKTOP", "Desktop") },
                { label: "Documents", icon: "document", path: win.xdgPath("DOCUMENTS", "Documents") },
                { label: "Downloads", icon: "download", path: win.xdgPath("DOWNLOAD", "Downloads") },
                { label: "Pictures", icon: "pictures", path: win.xdgPath("PICTURES", "Pictures") },
                { label: "Music", icon: "music", path: win.xdgPath("MUSIC", "Music") },
                { label: "Videos", icon: "video", path: win.xdgPath("VIDEOS", "Videos") },
                { separator: true },
                { label: "Projects", icon: "folder", path: win.xdgPath("PROJECTS", "Projects") },
                { label: "Trash", icon: "trash", path: Config.trash }
            ]

            function xdgPath(key: string, fallback: string): string {
                return win.xdg[key] ?? `${win.home}/${fallback}`;
            }

            function roleOf(path: string): string {
                const roles = [
                    ["DESKTOP", "Desktop", "desktop"], ["DOCUMENTS", "Documents", "documents"],
                    ["DOWNLOAD", "Downloads", "download"], ["MUSIC", "Music", "music"],
                    ["PICTURES", "Pictures", "pictures"], ["VIDEOS", "Videos", "videos"],
                    ["PROJECTS", "Projects", "projects"], ["TEMPLATES", "Templates", "templates"],
                    ["PUBLICSHARE", "Public", "public"]
                ];
                for (let i = 0; i < roles.length; i++) {
                    if (win.xdgPath(roles[i][0], roles[i][1]) === path)
                        return roles[i][2];
                }
                return "";
            }

            function rank(role: string): int {
                return ["desktop", "documents", "download", "music", "pictures", "videos", "projects", "templates", "public"].indexOf(role);
            }

            function iconFor(item: var): string {
                if (item.isDir) {
                    const role = win.roleOf(item.path);
                    return role !== "" ? `folder_${role}` : "folder_big";
                }
                const s = String(item.suffix).toLowerCase();
                if (["png", "jpg", "jpeg", "webp", "gif", "svg", "avif", "bmp", "heic"].indexOf(s) >= 0)
                    return "file_image";
                if (["mp3", "flac", "ogg", "opus", "wav", "m4a", "aac"].indexOf(s) >= 0)
                    return "file_audio";
                if (["mp4", "mkv", "webm", "mov", "avi"].indexOf(s) >= 0)
                    return "file_video";
                if (["zip", "tar", "gz", "xz", "zst", "7z", "rar", "bz2"].indexOf(s) >= 0)
                    return "file_archive";
                if (["py", "js", "ts", "qml", "lua", "sh", "rs", "c", "h", "cpp", "go", "java", "kt", "json", "toml", "yaml", "yml", "html", "css"].indexOf(s) >= 0)
                    return "file_code";
                return "file_big";
            }

            function goTo(next: string, remember = true): void {
                if (next === win.path)
                    return;
                if (remember) {
                    win.backStack = win.backStack.concat([win.path]);
                    win.forwardStack = [];
                }
                win.selected = -1;
                win.path = next;
            }

            function goBack(): void {
                if (!win.backStack.length)
                    return;
                const list = win.backStack.slice();
                const prev = list.pop();
                win.forwardStack = win.forwardStack.concat([win.path]);
                win.backStack = list;
                win.goTo(prev, false);
            }

            function goForward(): void {
                if (!win.forwardStack.length)
                    return;
                const list = win.forwardStack.slice();
                const next = list.pop();
                win.backStack = win.backStack.concat([win.path]);
                win.forwardStack = list;
                win.goTo(next, false);
            }

            function goUp(): void {
                if (win.path === "/" || win.path === "")
                    return;
                win.goTo(win.path.substring(0, win.path.lastIndexOf("/")) || "/");
            }

            function openItem(item: var): void {
                if (item.isDir)
                    win.goTo(item.path);
                else
                    Quickshell.execDetached(["xdg-open", item.path]);
            }

            function rebuild(): void {
                const out = [];
                const q = win.query.toLowerCase();
                for (let i = 0; i < folder.count; i++) {
                    const name = String(folder.get(i, "fileName"));
                    const file = String(folder.get(i, "filePath"));
                    if (!file.startsWith(win.path === "/" ? "/" : `${win.path}/`))
                        continue;
                    if (q !== "" && name.toLowerCase().indexOf(q) < 0)
                        continue;
                    out.push({
                        name: name,
                        path: file,
                        isDir: Boolean(folder.get(i, "fileIsDir")),
                        suffix: String(folder.get(i, "fileSuffix"))
                    });
                }
                out.sort((a, b) => {
                    if (a.isDir !== b.isDir)
                        return a.isDir ? -1 : 1;
                    const ra = win.rank(win.roleOf(a.path));
                    const rb = win.rank(win.roleOf(b.path));
                    if (ra !== rb)
                        return (ra < 0 ? 99 : ra) - (rb < 0 ? 99 : rb);
                    return a.name.localeCompare(b.name);
                });
                if (win.reversed)
                    out.reverse();
                win.items = out;
            }

            onQueryChanged: rebuild()
            onReversedChanged: rebuild()
            onXdgChanged: rebuild()

            Connections {
                target: GlobalState
                function onFilesPathChanged(): void {
                    if (GlobalState.filesPath !== "")
                        win.goTo(GlobalState.filesPath);
                }
            }

            FileView {
                path: `${win.home}/.config/user-dirs.dirs`
                onLoaded: {
                    const out = {};
                    const lines = text().split("\n");
                    for (let i = 0; i < lines.length; i++) {
                        const m = lines[i].match(/^XDG_(\w+)_DIR="(.*)"/);
                        if (m)
                            out[m[1]] = m[2].replace("$HOME", win.home);
                    }
                    win.xdg = out;
                }
            }

            FolderListModel {
                id: folder
                folder: "file://" + win.path.split("/").map(encodeURIComponent).join("/")
                showDirsFirst: true
                showHidden: win.showHidden
                showDotAndDotDot: false
                onCountChanged: win.rebuild()
                onStatusChanged: if (status === FolderListModel.Ready) win.rebuild()
            }

            Item {
                id: page
                anchors.fill: parent
                anchors.margins: 8 * win.u
                focus: true

                Keys.onPressed: e => {
                    if (e.key === Qt.Key_Backspace) {
                        win.goUp();
                        e.accepted = true;
                    } else if (e.key === Qt.Key_Left && (e.modifiers & Qt.AltModifier)) {
                        win.goBack();
                        e.accepted = true;
                    } else if (e.key === Qt.Key_Right && (e.modifiers & Qt.AltModifier)) {
                        win.goForward();
                        e.accepted = true;
                    } else if (e.key === Qt.Key_H && (e.modifiers & Qt.ControlModifier)) {
                        win.showHidden = !win.showHidden;
                        e.accepted = true;
                    } else if (e.key === Qt.Key_F && (e.modifiers & Qt.ControlModifier)) {
                        win.searching = true;
                        searchField.forceActiveFocus();
                        e.accepted = true;
                    }
                }

                Sheet {
                    anchors.fill: parent
                    u: win.u
                    variant: 2
                }

                Rectangle {
                    x: 2 * win.u
                    y: 2 * win.u
                    width: 86 * win.u
                    height: 42 * win.u
                    radius: 3 * win.u
                    color: Theme.paperDeep
                    opacity: 0.8
                }

                Rectangle {
                    x: 86 * win.u
                    y: 3 * win.u
                    width: parent.width - 89 * win.u
                    height: 41 * win.u
                    radius: 6 * win.u
                    color: Theme.paperLight
                    opacity: 0.7
                }

                Rectangle {
                    x: 2 * win.u
                    y: 44 * win.u
                    width: parent.width - 4 * win.u
                    height: Math.max(1, 0.5 * win.u)
                    color: Theme.line
                }

                Rectangle {
                    x: 129 * win.u
                    y: 44 * win.u
                    width: Math.max(1, 0.5 * win.u)
                    height: parent.height - 47 * win.u
                    color: Theme.line
                }

                Lights {
                    x: 18 * win.u
                    y: 17 * win.u
                    u: win.u
                    onCloseClicked: GlobalState.filesOpen = false
                    onMinClicked: {
                        const addr = Hyprland.activeToplevel?.lastIpcObject?.address ?? "";
                        if (addr !== "")
                            Hyprland.dispatch(`hl.dsp.window.move({ window = "address:${addr}", workspace = "special:min", follow = false })`);
                    }
                    onMaxClicked: Hyprland.dispatch(`hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })`)
                }

                Ico {
                    x: 100 * win.u
                    y: 14 * win.u
                    size: 18 * win.u
                    name: "folder_big"
                }

                Hand {
                    x: 126 * win.u
                    y: 3 * win.u
                    height: 40 * win.u
                    width: parent.width - 220 * win.u
                    visible: !win.searching
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    heavy: true
                    text: win.titleName
                    font.pixelSize: 18.5 * win.u
                }

                TextInput {
                    id: searchField
                    x: 126 * win.u
                    y: 3 * win.u
                    height: 40 * win.u
                    width: parent.width - 220 * win.u
                    visible: win.searching
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    color: Theme.ink
                    selectionColor: Theme.blueSoft
                    font.family: Theme.ui
                    font.pixelSize: 17 * win.u
                    onTextChanged: win.query = text
                    Keys.onEscapePressed: {
                        text = "";
                        win.searching = false;
                        page.forceActiveFocus();
                    }
                }

                IconButton {
                    x: 273 * win.u
                    y: 12 * win.u
                    u: win.u
                    size: 14 * win.u
                    box: 22 * win.u
                    icon: "search"
                    onClicked: {
                        win.searching = !win.searching;
                        if (win.searching) {
                            searchField.forceActiveFocus();
                        } else {
                            searchField.text = "";
                            page.forceActiveFocus();
                        }
                    }
                }

                IconButton {
                    x: 301 * win.u
                    y: 12 * win.u
                    u: win.u
                    size: 15 * win.u
                    box: 22 * win.u
                    icon: "sort"
                    onClicked: win.reversed = !win.reversed
                }

                IconButton {
                    x: 327 * win.u
                    y: 12 * win.u
                    u: win.u
                    size: 15 * win.u
                    box: 22 * win.u
                    icon: "dots"
                    onClicked: win.menuOpen = !win.menuOpen
                }

                Column {
                    x: 9 * win.u
                    y: 50 * win.u
                    width: 112 * win.u

                    Repeater {
                        model: win.places

                        Item {
                            id: place

                            required property var modelData
                            readonly property bool isSep: modelData.separator === true
                            readonly property bool current: !isSep && modelData.path === win.path

                            width: parent.width
                            height: isSep ? 4.5 * win.u : 28.8 * win.u

                            Rectangle {
                                visible: !place.isSep
                                anchors.fill: parent
                                anchors.topMargin: 1.4 * win.u
                                anchors.bottomMargin: 1.4 * win.u
                                radius: 5 * win.u
                                color: Theme.blueSoft
                                opacity: place.current ? 0.95 : (hover.containsMouse ? 0.4 : 0)
                                Behavior on opacity { NumberAnimation { duration: 90 } }
                            }

                            Ico {
                                visible: !place.isSep
                                x: 12 * win.u
                                anchors.verticalCenter: parent.verticalCenter
                                size: 15.5 * win.u
                                name: place.modelData.icon ?? ""
                            }

                            Hand {
                                visible: !place.isSep
                                x: 39 * win.u
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                text: place.modelData.label ?? ""
                                font.pixelSize: 15 * win.u
                                color: place.current ? Theme.ink : Theme.inkSoft
                            }

                            MouseArea {
                                id: hover
                                visible: !place.isSep
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.goTo(place.modelData.path)
                            }
                        }
                    }
                }

                GridView {
                    id: grid
                    x: 132 * win.u
                    y: 48 * win.u
                    width: parent.width - 135 * win.u
                    height: parent.height - 52 * win.u
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    cellWidth: width / Math.max(1, Math.floor(width / (72 * win.u)))
                    cellHeight: 88 * win.u
                    model: win.items

                    delegate: Item {
                        id: tile

                        required property var modelData
                        required property int index

                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2.5 * win.u
                            radius: 5 * win.u
                            color: Theme.blueSoft
                            opacity: win.selected === tile.index ? 0.7 : (tileMouse.containsMouse ? 0.3 : 0)
                        }

                        Ico {
                            x: (parent.width - size) / 2
                            y: 7 * win.u
                            size: 50 * win.u
                            name: win.iconFor(tile.modelData)
                        }

                        Hand {
                            y: 58 * win.u
                            x: 3 * win.u
                            width: parent.width - 6 * win.u
                            height: 26 * win.u
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignTop
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            lineHeight: 0.8
                            text: tile.modelData.name
                            font.pixelSize: 14.6 * win.u
                            color: Theme.inkSoft
                        }

                        MouseArea {
                            id: tileMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                win.selected = tile.index;
                                page.forceActiveFocus();
                            }
                            onDoubleClicked: win.openItem(tile.modelData)
                        }
                    }

                    Hand {
                        anchors.centerIn: parent
                        visible: win.items.length === 0
                        script: true
                        text: win.query !== "" ? "Nothing matches..." : "Nothing here..."
                        font.pixelSize: 20 * win.u
                        color: Theme.inkFaint
                    }
                }

                Rectangle {
                    visible: grid.contentHeight > grid.height
                    x: parent.width - 5 * win.u
                    y: grid.y + grid.visibleArea.yPosition * grid.height
                    width: 2.2 * win.u
                    height: grid.visibleArea.heightRatio * grid.height
                    radius: width / 2
                    color: Theme.inkFaint
                    opacity: 0.55
                }

                Item {
                    visible: win.menuOpen
                    x: parent.width - 148 * win.u
                    y: 40 * win.u
                    width: 138 * win.u
                    height: 90 * win.u
                    z: 5

                    Sheet {
                        anchors.fill: parent
                        u: win.u
                        variant: 0
                    }

                    Column {
                        x: 8 * win.u
                        y: 6 * win.u
                        width: parent.width - 16 * win.u

                        Repeater {
                            model: [
                                { label: win.showHidden ? "Hide hidden files" : "Show hidden files", run: () => win.showHidden = !win.showHidden },
                                { label: "Open terminal here", run: () => Quickshell.execDetached([`${Config.apps}/paper-term.sh`, "--directory", win.path]) },
                                { label: "Open in Dolphin", run: () => Quickshell.execDetached(["dolphin", win.path]) }
                            ]

                            Item {
                                id: entry

                                required property var modelData

                                width: parent.width
                                height: 26 * win.u

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4 * win.u
                                    color: Theme.blueSoft
                                    opacity: entryMouse.containsMouse ? 0.6 : 0
                                }

                                Hand {
                                    x: 6 * win.u
                                    height: parent.height
                                    verticalAlignment: Text.AlignVCenter
                                    text: entry.modelData.label
                                    font.pixelSize: 15 * win.u
                                }

                                MouseArea {
                                    id: entryMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        entry.modelData.run();
                                        win.menuOpen = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
