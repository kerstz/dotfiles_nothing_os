import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

Scope {
    WlSessionLock {
        locked: Lock.locked

        surface: WlSessionLockSurface {
            id: surface

            readonly property real u: Theme.unit(screen)

            color: "#20344d"

            Image {
                anchors.fill: parent
                source: Config.wallpaper !== "" ? `file://${Config.wallpaper}` : Theme.asset("wallpaper.png")
                fillMode: Image.PreserveAspectCrop
                horizontalAlignment: Image.AlignRight
                verticalAlignment: Image.AlignBottom
                asynchronous: true
            }

            SystemClock {
                id: clock
                precision: SystemClock.Seconds
            }

            Timer {
                interval: 400
                running: true
                repeat: true
                onTriggered: {
                    if (!field.activeFocus)
                        field.forceActiveFocus();
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: field.forceActiveFocus()
            }

            Item {
                id: note
                anchors.centerIn: parent
                width: 300 * surface.u
                height: 230 * surface.u

                property real shift: 0
                transform: Translate { x: note.shift }

                SequentialAnimation {
                    id: shakeAnim
                    NumberAnimation { target: note; property: "shift"; to: -9 * surface.u; duration: 50 }
                    NumberAnimation { target: note; property: "shift"; to: 9 * surface.u; duration: 70 }
                    NumberAnimation { target: note; property: "shift"; to: -5 * surface.u; duration: 60 }
                    NumberAnimation { target: note; property: "shift"; to: 0; duration: 50 }
                }

                Connections {
                    target: Lock
                    function onShakeChanged(): void {
                        shakeAnim.restart();
                    }
                }

                Sheet {
                    anchors.fill: parent
                    u: surface.u
                    variant: 2
                }

                Tape {
                    tone: "tan"
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: -9 * surface.u
                    width: 62 * surface.u
                    height: 20 * surface.u
                    rotation: -3
                }

                Hand {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 12 * surface.u
                    script: true
                    text: Config.clock24 ? clock.date.toLocaleString(Config.locale, "HH:mm") : clock.date.toLocaleString(Config.locale, "h:mm AP")
                    font.pixelSize: 54 * surface.u
                }

                Hand {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 92 * surface.u
                    text: clock.date.toLocaleString(Config.locale, "dddd, d MMMM yyyy")
                    font.pixelSize: 17 * surface.u
                    color: Theme.inkSoft
                }

                Rectangle {
                    x: 40 * surface.u
                    y: 130 * surface.u
                    width: parent.width - 80 * surface.u
                    height: 28 * surface.u
                    radius: 14 * surface.u
                    color: Theme.paperLight
                    border.width: Math.max(1, 0.6 * surface.u)
                    border.color: Lock.notice !== "" ? Theme.red : Theme.inkSoft

                    TextInput {
                        id: field
                        anchors.fill: parent
                        anchors.leftMargin: 14 * surface.u
                        anchors.rightMargin: 14 * surface.u
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        passwordCharacter: "*"
                        enabled: !Lock.busy
                        focus: true
                        clip: true
                        color: Theme.ink
                        font.family: Theme.ui
                        font.pixelSize: 18 * surface.u
                        text: Lock.secret
                        onTextEdited: Lock.secret = text
                        onAccepted: Lock.submit()
                        Component.onCompleted: forceActiveFocus()
                    }

                    Hand {
                        anchors.centerIn: parent
                        visible: field.text === ""
                        text: Lock.busy ? "Checking..." : "Password"
                        font.pixelSize: 15.5 * surface.u
                        color: Theme.inkFaint
                    }
                }

                Hand {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 168 * surface.u
                    visible: Lock.notice !== ""
                    text: Lock.notice
                    font.pixelSize: 15.5 * surface.u
                    color: Theme.red
                }

                Hand {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 192 * surface.u
                    text: Quickshell.env("USER") ?? ""
                    font.pixelSize: 14.5 * surface.u
                    color: Theme.inkFaint
                }
            }
        }
    }
}
