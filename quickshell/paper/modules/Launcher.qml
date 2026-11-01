import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import ".."
import "../components"

PanelWindow {
    id: win

    required property var modelData
    readonly property real u: Theme.unit(modelData)
    readonly property bool focused: Hyprland.focusedMonitor?.name === modelData.name
    property string query: ""
    property int current: 0

    screen: modelData
    visible: GlobalState.launcherOpen && focused
    color: "#33000000"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "paper-launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }

    readonly property var results: {
        const list = DesktopEntries.applications?.values ?? [];
        const q = win.query.toLowerCase();
        const out = [];
        for (let i = 0; i < list.length; i++) {
            const e = list[i];
            if (e.noDisplay)
                continue;
            if (q === "" || String(e.name).toLowerCase().indexOf(q) >= 0 || String(e.genericName ?? "").toLowerCase().indexOf(q) >= 0)
                out.push(e);
        }
        out.sort((a, b) => String(a.name).localeCompare(String(b.name)));
        return out;
    }

    onVisibleChanged: {
        if (visible) {
            win.query = "";
            win.current = 0;
            field.text = "";
            field.forceActiveFocus();
        }
    }

    function launch(entry: var): void {
        if (!entry)
            return;
        entry.execute();
        GlobalState.launcherOpen = false;
    }

    MouseArea {
        anchors.fill: parent
        onClicked: GlobalState.launcherOpen = false
    }

    Item {
        id: note
        anchors.centerIn: parent
        width: 280 * win.u
        height: 300 * win.u

        MouseArea { anchors.fill: parent }

        Sheet {
            anchors.fill: parent
            u: win.u
            variant: 1
        }

        Tape {
            tone: "tan"
            anchors.horizontalCenter: parent.horizontalCenter
            y: -8 * win.u
            width: 60 * win.u
            height: 20 * win.u
            rotation: -3
        }

        Ico {
            x: 16 * win.u
            y: 19 * win.u
            size: 14 * win.u
            name: "search"
        }

        TextInput {
            id: field
            x: 38 * win.u
            y: 14 * win.u
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
            Keys.onEscapePressed: GlobalState.launcherOpen = false
            Keys.onReturnPressed: win.launch(win.results[win.current])
            Keys.onEnterPressed: win.launch(win.results[win.current])
            Keys.onDownPressed: {
                win.current = Math.min(win.results.length - 1, win.current + 1);
                list.positionViewAtIndex(win.current, ListView.Contain);
            }
            Keys.onUpPressed: {
                win.current = Math.max(0, win.current - 1);
                list.positionViewAtIndex(win.current, ListView.Contain);
            }
        }

        Rectangle {
            x: 14 * win.u
            y: 41 * win.u
            width: parent.width - 28 * win.u
            height: Math.max(1, 0.6 * win.u)
            color: Theme.line
        }

        ListView {
            id: list
            x: 10 * win.u
            y: 46 * win.u
            width: parent.width - 20 * win.u
            height: parent.height - 56 * win.u
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: win.results
            spacing: 0

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

                Image {
                    x: 7 * win.u
                    anchors.verticalCenter: parent.verticalCenter
                    width: 17 * win.u
                    height: 17 * win.u
                    source: Quickshell.iconPath(row.modelData.icon ?? "", true)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    asynchronous: true
                }

                Hand {
                    x: 31 * win.u
                    width: parent.width - 38 * win.u
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    text: row.modelData.name
                    font.pixelSize: 16.5 * win.u
                    color: Theme.ink
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: win.current = row.index
                    onClicked: win.launch(row.modelData)
                }
            }
        }
    }
}
