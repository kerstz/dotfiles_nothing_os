import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import ".."
import "../components"
import "../services"

// The bottom taskbar: start orb, pinned launchers, running-window buttons,
// system tray, and the clock. Windows-like in shape, glacial in colour.
PanelWindow {
    id: win
    required property var modelData

    screen: modelData
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "nocturne-taskbar"

    anchors { bottom: true; left: true; right: true }
    implicitHeight: Theme.z.bar + Theme.px(10)
    exclusiveZone: Theme.z.bar

    readonly property var tray: SystemTray.items?.values ?? []

    Frost {
        id: bar
        anchors.fill: parent
        anchors.leftMargin: Theme.px(6)
        anchors.rightMargin: Theme.px(6)
        anchors.bottomMargin: Theme.px(6)
        anchors.topMargin: Theme.px(2)
        radius: Theme.r.card
        alpha: 0.9

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.px(6)
            anchors.rightMargin: Theme.px(10)
            spacing: Theme.px(6)

            // ── Start orb ──────────────────────────────────────────────
            Item {
                Layout.preferredWidth: Theme.z.taskBtn + Theme.px(4)
                Layout.preferredHeight: Theme.z.taskBtn
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    id: orb
                    anchors.centerIn: parent
                    width: Theme.px(30)
                    height: width
                    radius: width / 2
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0; color: Theme.c.accent2 }
                        GradientStop { position: 1; color: Theme.c.accent }
                    }
                    scale: startMa.pressed ? 0.9 : (startMa.containsMouse || GlobalState.startOpen ? 1.08 : 1)
                    Behavior on scale { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutQuad } }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + Theme.px(10)
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: 2
                        border.color: Theme.tint(Theme.c.accent, GlobalState.startOpen ? 0.5 : 0.0)
                        Behavior on border.color { ColorAnimation { duration: Theme.med } }
                    }

                    // A small dot-mark, nocturne's sigil.
                    Grid {
                        anchors.centerIn: parent
                        columns: 2
                        spacing: Theme.px(3)
                        Repeater {
                            model: 4
                            Rectangle {
                                width: Theme.px(4); height: width; radius: width / 2
                                color: Theme.c.accentInk
                            }
                        }
                    }
                }

                MouseArea {
                    id: startMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: GlobalState.toggleStart()
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: Theme.px(20)
                color: Theme.c.outline
            }

            // ── Pinned launchers (not running) ─────────────────────────
            Repeater {
                model: Config.pinnedList().filter(id => !win.classRunning(Apps.classFor(id)))
                delegate: TaskButton {
                    required property var modelData
                    pinnedId: modelData
                    appClass: Apps.classFor(modelData)
                    label: Apps.nameFor(modelData)
                    running: false
                    onLeftClick: Apps.launch(pinnedId)
                }
            }

            // ── Running windows ────────────────────────────────────────
            Repeater {
                model: Windows.toplevels
                delegate: TaskButton {
                    required property var modelData
                    readonly property string addr: Windows.addressOf(modelData)
                    appClass: Windows.classOf(modelData)
                    label: Windows.titleOf(modelData) || Windows.classOf(modelData)
                    running: true
                    active: addr !== "" && addr === Windows.activeAddress
                    showLabel: true
                    onLeftClick: {
                        if (active) Windows.minimise(addr);
                        else if (modelData.workspace?.name === "special:min") Windows.restore(addr);
                        else Windows.focus(addr);
                    }
                    onCloseClick: Windows.close(addr)
                }
            }

            Item { Layout.fillWidth: true }

            // ── System tray ────────────────────────────────────────────
            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: Theme.px(2)
                Repeater {
                    model: win.tray
                    delegate: Item {
                        required property var modelData
                        Layout.preferredWidth: Theme.px(26)
                        Layout.preferredHeight: Theme.px(26)

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.r.tiny
                            color: tma.containsMouse ? Theme.c.surface3 : "transparent"
                            Behavior on color { ColorAnimation { duration: Theme.fast } }
                        }
                        Image {
                            anchors.centerIn: parent
                            width: Theme.z.icon
                            height: Theme.z.icon
                            source: modelData.icon ?? ""
                            sourceSize.width: width * 2
                            sourceSize.height: height * 2
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }
                        MouseArea {
                            id: tma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: (m) => {
                                if (m.button === Qt.RightButton && modelData.hasMenu)
                                    modelData.display(win, tma.x, tma.y + parent.height);
                                else
                                    modelData.activate();
                            }
                        }
                    }
                }
            }

            Rectangle {
                visible: win.tray.length > 0
                Layout.preferredWidth: 1
                Layout.preferredHeight: Theme.px(20)
                color: Theme.c.outline
            }

            // ── Clock ──────────────────────────────────────────────────
            Item {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: clockCol.implicitWidth + Theme.px(16)
                Layout.preferredHeight: Theme.z.taskBtn

                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: Theme.px(3)
                    anchors.bottomMargin: Theme.px(3)
                    radius: Theme.r.chip
                    color: cma.containsMouse || GlobalState.calendarOpen
                        ? Theme.c.surface3 : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.fast } }
                }

                ColumnLayout {
                    id: clockCol
                    anchors.centerIn: parent
                    spacing: 0
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Time.clockText
                        font.family: Theme.f.sans
                        font.pixelSize: Theme.f.body
                        font.weight: Font.Medium
                        color: Theme.c.on
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Time.dateText
                        font.family: Theme.f.sans
                        font.pixelSize: Theme.f.micro
                        color: Theme.c.onDim
                    }
                }

                MouseArea {
                    id: cma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: GlobalState.toggleCalendar(0)
                }
            }

            // ── Power ──────────────────────────────────────────────────
            Item {
                Layout.preferredWidth: Theme.px(30)
                Layout.preferredHeight: Theme.z.taskBtn
                Layout.alignment: Qt.AlignVCenter
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: Theme.px(3)
                    anchors.bottomMargin: Theme.px(3)
                    radius: Theme.r.chip
                    color: pma.containsMouse ? Theme.c.surface3 : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.fast } }
                }
                Glyph {
                    anchors.centerIn: parent
                    text: ""
                    size: Theme.z.icon
                    color: pma.containsMouse ? Theme.c.magenta : Theme.c.onDim
                }
                MouseArea {
                    id: pma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: GlobalState.togglePower()
                }
            }
        }
    }

    readonly property var openClasses: {
        const out = {};
        for (const t of Windows.toplevels) {
            const c = Windows.classOf(t).toLowerCase();
            if (c) out[c] = true;
        }
        return out;
    }
    function classRunning(c: string): bool {
        return win.openClasses[(c ?? "").toLowerCase()] ?? false;
    }
}
