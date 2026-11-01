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

    screen: modelData
    visible: GlobalState.sessionOpen && focused
    color: "#44000000"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "paper-session"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }

    readonly property var actions: [
        { label: "Lock", icon: "lock", cmd: ["loginctl", "lock-session"] },
        { label: "Log out", icon: "logout", cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
        { label: "Restart", icon: "restart", cmd: ["systemctl", "reboot"] },
        { label: "Power off", icon: "power", cmd: ["systemctl", "poweroff"] }
    ]

    MouseArea {
        anchors.fill: parent
        onClicked: GlobalState.sessionOpen = false
    }

    Item {
        anchors.fill: parent
        focus: win.visible
        Keys.onEscapePressed: GlobalState.sessionOpen = false
    }

    Item {
        anchors.centerIn: parent
        width: 330 * win.u
        height: 110 * win.u

        MouseArea { anchors.fill: parent }

        Sheet {
            anchors.fill: parent
            u: win.u
            variant: 2
        }

        Tape {
            tone: "pink"
            x: parent.width - 62 * win.u
            y: -7 * win.u
            width: 46 * win.u
            height: 15 * win.u
            rotation: 5
        }

        Row {
            anchors.centerIn: parent
            spacing: 8 * win.u

            Repeater {
                model: win.actions

                Item {
                    id: button

                    required property var modelData

                    width: 72 * win.u
                    height: 82 * win.u

                    Rectangle {
                        anchors.fill: parent
                        radius: 6 * win.u
                        color: Theme.blueSoft
                        opacity: buttonMouse.containsMouse ? 0.7 : 0
                        Behavior on opacity { NumberAnimation { duration: 90 } }
                    }

                    Ico {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 12 * win.u
                        size: 32 * win.u
                        name: button.modelData.icon
                    }

                    Hand {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 52 * win.u
                        text: button.modelData.label
                        font.pixelSize: 16 * win.u
                    }

                    MouseArea {
                        id: buttonMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            GlobalState.sessionOpen = false;
                            Quickshell.execDetached(button.modelData.cmd);
                        }
                    }
                }
            }
        }
    }
}
