import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

// The start menu: search, pinned tiles and the full app list, anchored at
// the bottom-left above the taskbar. A full-screen catcher dismisses it.
PanelWindow {
    id: win

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nocturne-start"
    WlrLayershell.keyboardFocus: GlobalState.startOpen
        ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors { top: true; bottom: true; left: true; right: true }

    readonly property bool open: GlobalState.startOpen

    mask: Region { item: open ? null : dummy }
    Item { id: dummy }

    property string query: GlobalState.startQuery

    readonly property var results: Apps.search(query)
    readonly property var pins: Config.pinnedList()
        .map(id => Apps.entry(id))
        .filter(e => e !== null)

    function run(entry): void {
        if (!entry) return;
        entry.execute();
        GlobalState.startOpen = false;
    }

    // Click-away catcher.
    MouseArea {
        anchors.fill: parent
        enabled: win.open
        onClicked: GlobalState.startOpen = false
    }

    Frost {
        id: panel
        width: Theme.z.start
        height: Math.min(parent.height - Theme.px(80), Theme.px(620))
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: Theme.px(10)
        anchors.bottomMargin: Theme.z.bar + Theme.px(14)
        radius: Theme.r.panel
        alpha: 0.9
        visible: win.open || opacity > 0.01
        opacity: win.open ? 1 : 0
        y: win.open ? baseY : baseY + Theme.px(24)
        readonly property real baseY:
            parent.height - height - (Theme.z.bar + Theme.px(14))
        Behavior on opacity { NumberAnimation { duration: Theme.med } }
        Behavior on y { NumberAnimation { duration: Theme.med; easing.type: Theme.ease } }

        // Swallow clicks so they do not reach the catcher.
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.pad
            spacing: Theme.gap

            // ── Search ─────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.px(40)
                radius: Theme.r.chip
                color: Theme.c.surface2
                border.width: search.activeFocus ? 1 : 0
                border.color: Theme.tint(Theme.c.accent, 0.5)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.px(12)
                    anchors.rightMargin: Theme.px(12)
                    spacing: Theme.px(8)
                    Glyph { text: ""; size: Theme.z.icon; color: Theme.c.onDim }
                    TextInput {
                        id: search
                        Layout.fillWidth: true
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: Theme.f.sans
                        font.pixelSize: Theme.f.body
                        color: Theme.c.on
                        clip: true
                        focus: win.open
                        text: win.query
                        onTextChanged: win.query = text
                        Keys.onEscapePressed: GlobalState.startOpen = false
                        Keys.onReturnPressed: {
                            if (win.results.length > 0) win.run(win.results[0]);
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: search.text === ""
                            text: "Search apps"
                            font: search.font
                            color: Theme.c.onFaint
                        }
                    }
                }
            }

            Text {
                text: win.query === "" ? "PINNED" : "RESULTS"
                font.family: Theme.f.sans
                font.pixelSize: Theme.f.micro
                font.letterSpacing: Theme.f.track
                font.weight: Font.DemiBold
                color: Theme.c.onFaint
            }

            // ── Pinned grid (empty query) ──────────────────────────────
            GridView {
                id: grid
                visible: win.query === ""
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: width / 5
                cellHeight: Theme.z.startTile
                model: win.pins
                delegate: Item {
                    required property var modelData
                    width: grid.cellWidth
                    height: grid.cellHeight
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Theme.px(4)
                        radius: Theme.r.card
                        color: gma.containsMouse ? Theme.c.surface3 : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.fast } }
                    }
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.px(6)
                        AppIcon {
                            Layout.alignment: Qt.AlignHCenter
                            appId: modelData.id
                            size: Theme.z.iconL + Theme.px(8)
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.maximumWidth: grid.cellWidth - Theme.px(10)
                            text: modelData.name
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Theme.f.sans
                            font.pixelSize: Theme.f.tiny
                            color: Theme.c.onDim
                        }
                    }
                    MouseArea {
                        id: gma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: win.run(modelData)
                    }
                }
            }

            // ── Results list (query typed) ─────────────────────────────
            ListView {
                id: list
                visible: win.query !== ""
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: win.results
                spacing: Theme.px(2)
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: list.width
                    height: Theme.px(46)
                    radius: Theme.r.chip
                    color: lma.containsMouse || index === 0
                        ? Theme.c.surface3 : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.fast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.px(10)
                        anchors.rightMargin: Theme.px(10)
                        spacing: Theme.px(12)
                        AppIcon { appId: modelData.id; size: Theme.z.iconL }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                text: modelData.name
                                font.family: Theme.f.sans
                                font.pixelSize: Theme.f.body
                                color: Theme.c.on
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                visible: (modelData.genericName ?? "") !== ""
                                text: modelData.genericName ?? ""
                                font.family: Theme.f.sans
                                font.pixelSize: Theme.f.micro
                                color: Theme.c.onFaint
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                    MouseArea {
                        id: lma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: win.run(modelData)
                    }
                }
            }

            // ── Footer ─────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.gap
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.c.outline }
                StartFootButton {
                    glyph: ""; label: "Settings"
                    onActivated: { GlobalState.startOpen = false; Apps.launch("systemsettings"); }
                }
                StartFootButton {
                    glyph: ""; label: "Power"
                    onActivated: GlobalState.togglePower()
                }
            }
        }
    }

    onOpenChanged: if (open) { search.text = GlobalState.startQuery; search.forceActiveFocus(); }
}
