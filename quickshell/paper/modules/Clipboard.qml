import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../components"
import "../services"

OverlayPanel {
    id: win

    property var entries: []
    property string query: ""
    property int current: 0

    readonly property var shown: {
        const q = win.query.toLowerCase();
        return q === "" ? win.entries : win.entries.filter(e => e.text.toLowerCase().indexOf(q) >= 0);
    }

    open: GlobalState.clipboardOpen
    panelWidth: 320
    panelHeight: 340
    tape: "tan"
    onDismissed: GlobalState.clipboardOpen = false

    onVisibleChanged: {
        if (visible) {
            win.query = "";
            win.current = 0;
            search.text = "";
            Quickshell.execDetached([`${Sys.scripts}/ensure-cliphist.sh`]);
            lister.running = true;
            search.forceActiveFocus();
        }
    }

    function pick(entry: var): void {
        if (!entry)
            return;
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "sh", entry.raw]);
        GlobalState.clipboardOpen = false;
    }

    function remove(entry: var): void {
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist delete", "sh", entry.raw]);
        win.entries = win.entries.filter(e => e !== entry);
    }

    Process {
        id: lister
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                const lines = this.text.split("\n");
                for (let i = 0; i < lines.length && i < 200; i++) {
                    const line = lines[i];
                    const tab = line.indexOf("\t");
                    if (tab > 0)
                        out.push({ raw: line, text: line.slice(tab + 1) });
                }
                win.entries = out;
            }
        }
    }

    Ico {
        x: 16 * win.u
        y: 18 * win.u
        size: 14 * win.u
        name: "search"
    }

    TextInput {
        id: search
        x: 38 * win.u
        y: 13 * win.u
        width: parent.width - 54 * win.u
        height: 24 * win.u
        verticalAlignment: TextInput.AlignVCenter
        clip: true
        color: Theme.ink
        selectionColor: Theme.blueSoft
        font.family: Theme.ui
        font.pixelSize: 18 * win.u
        onTextChanged: {
            win.query = text;
            win.current = 0;
        }
        Keys.onEscapePressed: GlobalState.clipboardOpen = false
        Keys.onReturnPressed: win.pick(win.shown[win.current])
        Keys.onDownPressed: {
            win.current = Math.min(win.shown.length - 1, win.current + 1);
            list.positionViewAtIndex(win.current, ListView.Contain);
        }
        Keys.onUpPressed: {
            win.current = Math.max(0, win.current - 1);
            list.positionViewAtIndex(win.current, ListView.Contain);
        }
    }

    Rectangle {
        x: 14 * win.u
        y: 40 * win.u
        width: parent.width - 28 * win.u
        height: Math.max(1, 0.6 * win.u)
        color: Theme.line
    }

    ListView {
        id: list
        x: 10 * win.u
        y: 45 * win.u
        width: parent.width - 20 * win.u
        height: parent.height - 55 * win.u
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: win.shown

        delegate: Item {
            id: row

            required property var modelData
            required property int index

            width: list.width
            height: 28 * win.u

            Rectangle {
                anchors.fill: parent
                radius: 5 * win.u
                color: Theme.blueSoft
                opacity: win.current === row.index ? 0.85 : 0
            }

            Hand {
                x: 8 * win.u
                width: parent.width - 34 * win.u
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: row.modelData.text
                font.pixelSize: 15.5 * win.u
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: win.current = row.index
                onClicked: win.pick(row.modelData)
            }

            IconButton {
                x: parent.width - 24 * win.u
                y: 5 * win.u
                u: win.u
                size: 9 * win.u
                box: 18 * win.u
                icon: "close"
                onClicked: win.remove(row.modelData)
            }
        }

        Hand {
            anchors.centerIn: parent
            visible: win.shown.length === 0
            script: true
            text: "Nothing copied yet..."
            font.pixelSize: 20 * win.u
            color: Theme.inkFaint
        }
    }
}
