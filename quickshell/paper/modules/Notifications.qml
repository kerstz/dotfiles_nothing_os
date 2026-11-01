import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

Scope {
    id: scope

    PanelWindow {
        id: win

        readonly property var targetScreen: Quickshell.screens[0]
        readonly property real u: Theme.unit(targetScreen)

        screen: targetScreen
        visible: Notifs.popups.length > 0
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "paper-notifications"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; right: true }
        margins { top: 38 * u; right: 196 * u }
        implicitWidth: Math.round(230 * u)
        implicitHeight: Math.max(1, stack.implicitHeight + 20 * u)

        Column {
            id: stack
            x: 8 * win.u
            y: 8 * win.u
            width: parent.width - 16 * win.u
            spacing: 10 * win.u

            Repeater {
                model: Notifs.popups

                Item {
                    id: note

                    required property var modelData

                    width: stack.width
                    height: Math.max(52 * win.u, body.y + body.implicitHeight + 10 * win.u)

                    Timer {
                        interval: Math.max(3000, note.modelData.expireTimeout > 0 ? note.modelData.expireTimeout : 6000)
                        running: true
                        onTriggered: Notifs.dropPopup(note.modelData)
                    }

                    Sheet {
                        anchors.fill: parent
                        u: win.u
                        variant: 1
                    }

                    Tape {
                        tone: "pink"
                        x: parent.width - 44 * win.u
                        y: -5 * win.u
                        width: 36 * win.u
                        height: 12 * win.u
                        rotation: 6
                    }

                    Hand {
                        x: 11 * win.u
                        y: 7 * win.u
                        width: parent.width - 22 * win.u
                        elide: Text.ElideRight
                        text: note.modelData.summary || note.modelData.appName
                        font.pixelSize: 16.5 * win.u
                        heavy: true
                    }

                    Hand {
                        id: body
                        x: 11 * win.u
                        y: 27 * win.u
                        width: parent.width - 22 * win.u
                        wrapMode: Text.WordWrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                        text: note.modelData.body
                        font.pixelSize: 15 * win.u
                        color: Theme.inkSoft
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.dismiss(note.modelData)
                    }
                }
            }
        }
    }
}
