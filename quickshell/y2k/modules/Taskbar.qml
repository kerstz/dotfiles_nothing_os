import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import ".."
import "../components"

PanelWindow {
    id: win
    required property var modelData

    screen: modelData
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "y2k-taskbar"

    anchors { bottom: true; left: true; right: true }
    implicitHeight: Theme.z.taskbar
    exclusiveZone: Theme.z.taskbar

    readonly property var trayItems: SystemTray.items?.values ?? []
    readonly property var toplevels: Hyprland.toplevels?.values ?? []

    Timer { id: refresh; interval: 80; onTriggered: Hyprland.refreshToplevels() }
    Connections {
        target: Hyprland
        function onRawEvent(e: var): void {
            const n = e.name;
            if (n === "openwindow" || n === "closewindow" || n === "movewindow"
                || n === "movewindowv2" || n === "activewindow" || n === "activewindowv2"
                || n === "windowtitle" || n === "windowtitlev2" || n === "workspace"
                || n === "workspacev2" || n === "fullscreen")
                refresh.restart();
        }
    }
    Component.onCompleted: Hyprland.refreshToplevels()

    function focusWin(addr: string): void {
        if (addr !== "")
            Hyprland.dispatch(`hl.dsp.focus({ window = "address:${addr}" })`);
    }

    Bevel {
        anchors.fill: parent
        face: Theme.c.face
        raised: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.px(2)
            spacing: Theme.gap

            // ── Start button ──────────────────────────────────────────
            BevelButton {
                Layout.preferredWidth: Theme.z.start
                Layout.fillHeight: true
                active: GlobalState.startOpen
                onClicked: GlobalState.toggleStart()

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.px(6)

                    // Loud four-pane Y2K flag.
                    Grid {
                        columns: 2
                        rowSpacing: Theme.px(1)
                        columnSpacing: Theme.px(1)
                        Repeater {
                            model: [Theme.c.pink, Theme.c.lime, Theme.c.cyan, Theme.c.yellow]
                            Rectangle {
                                required property var modelData
                                width: Theme.px(7); height: Theme.px(7)
                                color: modelData
                                border.width: 1
                                border.color: Theme.c.dark
                            }
                        }
                    }
                    Text {
                        text: "start"
                        color: Theme.c.ink
                        font.family: Theme.f.arcade
                        font.pixelSize: Theme.f.micro
                        renderType: Text.NativeRendering
                    }
                }
            }

            Groove { Layout.fillHeight: true; Layout.topMargin: Theme.px(3); Layout.bottomMargin: Theme.px(3) }

            // ── Task buttons ──────────────────────────────────────────
            RowLayout {
                id: taskRow
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.px(3)

                Repeater {
                    model: win.toplevels

                    BevelButton {
                        id: task
                        required property var modelData
                        readonly property var ipc: modelData.lastIpcObject ?? ({})
                        readonly property string addr: String(ipc.address ?? "")
                        readonly property string cls: String(ipc.class ?? "")
                        readonly property bool focused: modelData.activated ?? false

                        Layout.fillWidth: true
                        Layout.maximumWidth: Theme.z.task
                        Layout.preferredWidth: Theme.z.task
                        Layout.fillHeight: true
                        active: focused
                        face: Theme.c.face
                        onClicked: win.focusWin(addr)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.px(5)
                            anchors.rightMargin: Theme.px(5)
                            spacing: Theme.px(5)

                            AppGlyph {
                                Layout.alignment: Qt.AlignVCenter
                                size: Theme.z.icon
                                name: task.cls
                                fallbackText: task.cls
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                text: (modelData.title && String(modelData.title).length > 0)
                                    ? String(modelData.title) : task.cls
                                color: Theme.c.ink
                                font.family: Theme.f.display
                                font.pixelSize: Theme.f.tiny
                                font.bold: task.focused
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
                Item { Layout.fillWidth: true }
            }

            Groove { Layout.fillHeight: true; Layout.topMargin: Theme.px(3); Layout.bottomMargin: Theme.px(3) }

            // ── System tray ───────────────────────────────────────────
            Bevel {
                Layout.fillHeight: true
                Layout.topMargin: Theme.px(3)
                Layout.bottomMargin: Theme.px(3)
                Layout.preferredWidth: trayRow.implicitWidth + Theme.px(10)
                visible: win.trayItems.length > 0
                raised: false
                face: Theme.c.face

                Row {
                    id: trayRow
                    anchors.centerIn: parent
                    spacing: Theme.px(4)

                    Repeater {
                        model: win.trayItems
                        Item {
                            id: tr
                            required property var modelData
                            width: Theme.z.tray; height: Theme.z.tray

                            Image {
                                anchors.centerIn: parent
                                width: Theme.z.icon; height: Theme.z.icon
                                source: tr.modelData.icon
                                smooth: false
                                fillMode: Image.PreserveAspectFit
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: (m) => {
                                    if (m.button === Qt.RightButton || tr.modelData.onlyMenu) {
                                        const pt = tr.mapToItem(null, 0, 0);
                                        tr.modelData.display(win, pt.x, pt.y);
                                    } else {
                                        tr.modelData.activate();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Clock ─────────────────────────────────────────────────
            Bevel {
                Layout.fillHeight: true
                Layout.topMargin: Theme.px(3)
                Layout.bottomMargin: Theme.px(3)
                Layout.preferredWidth: clockCol.implicitWidth + Theme.px(16)
                raised: false
                face: Theme.c.well

                Column {
                    id: clockCol
                    anchors.centerIn: parent
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Clock.hhmm
                        color: Theme.c.phosphor
                        font.family: Theme.f.crt
                        font.pixelSize: Theme.f.big
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }
}
