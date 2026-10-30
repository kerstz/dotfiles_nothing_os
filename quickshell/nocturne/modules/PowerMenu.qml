import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"

// A centred frosted power dialog: lock, suspend, logout, reboot, power off.
PanelWindow {
    id: win

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nocturne-power"
    WlrLayershell.keyboardFocus: GlobalState.powerOpen
        ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors { top: true; bottom: true; left: true; right: true }

    readonly property bool open: GlobalState.powerOpen

    mask: Region { item: open ? null : dummy }
    Item { id: dummy }

    function run(cmd: string): void {
        GlobalState.powerOpen = false;
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.c.scrim
        opacity: win.open ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: Theme.med } }
        MouseArea { anchors.fill: parent; onClicked: GlobalState.powerOpen = false }
        focus: win.open
        Keys.onEscapePressed: GlobalState.powerOpen = false
    }

    Frost {
        anchors.centerIn: parent
        width: rowl.implicitWidth + Theme.pad * 2
        height: Theme.px(150)
        radius: Theme.r.panel
        alpha: 0.92
        visible: win.open || opacity > 0.01
        opacity: win.open ? 1 : 0
        scale: win.open ? 1 : 0.95
        Behavior on opacity { NumberAnimation { duration: Theme.med } }
        Behavior on scale { NumberAnimation { duration: Theme.med; easing.type: Theme.ease } }

        MouseArea { anchors.fill: parent }

        RowLayout {
            id: rowl
            anchors.centerIn: parent
            spacing: Theme.gap

            Repeater {
                model: [
                    { g: "", t: "Lock",    c: "loginctl lock-session || hyprlock" },
                    { g: "", t: "Suspend", c: "systemctl suspend || loginctl suspend" },
                    { g: "", t: "Log out", c: "hyprctl dispatch exit || loginctl terminate-user $USER" },
                    { g: "", t: "Restart", c: "systemctl reboot || loginctl reboot" },
                    { g: "", t: "Shut down", c: "systemctl poweroff || loginctl poweroff" }
                ]
                delegate: Item {
                    required property var modelData
                    Layout.preferredWidth: Theme.px(92)
                    Layout.preferredHeight: Theme.px(104)

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.r.card
                        color: bma.containsMouse ? Theme.tint(Theme.c.accent, 0.18) : Theme.c.surface2
                        border.width: bma.containsMouse ? 1 : 0
                        border.color: Theme.tint(Theme.c.accent, 0.5)
                        Behavior on color { ColorAnimation { duration: Theme.fast } }
                    }
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.px(12)
                        Glyph {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.g
                            size: Theme.z.iconL + Theme.px(2)
                            color: bma.containsMouse ? Theme.c.accent2 : Theme.c.on
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.t
                            font.family: Theme.f.sans
                            font.pixelSize: Theme.f.small
                            color: Theme.c.onDim
                        }
                    }
                    MouseArea {
                        id: bma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: win.run(modelData.c)
                    }
                    scale: bma.pressed ? 0.93 : 1
                    Behavior on scale { NumberAnimation { duration: Theme.fast } }
                }
            }
        }
    }
}
