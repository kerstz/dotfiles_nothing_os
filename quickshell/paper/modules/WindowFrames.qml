import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import ".."
import "../components"
import "../services"

PanelWindow {
    id: win

    required property var modelData
    readonly property real u: Theme.unit(modelData)
    readonly property var monitor: Hyprland.monitorFor(modelData)

    screen: modelData
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "paper-frames"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }

    function kind(cls: string): string {
        if (cls === "org.quickshell")
            return "self";
        if (cls === "paper-firefox")
            return "bare";
        if (cls === "kitty")
            return "terminal";
        return "titled";
    }

    Repeater {
        model: Windows.all

        Item {
            id: frame

            required property var modelData
            readonly property var ipc: modelData.lastIpcObject ?? ({})
            readonly property string cls: String(ipc.class ?? "")
            readonly property string addr: String(ipc.address ?? "")
            readonly property string kindName: win.kind(cls)
            readonly property bool titled: kindName === "terminal" || kindName === "titled"
            readonly property real insetTop: titled ? 34 * win.u : 3 * win.u
            readonly property real insetSide: titled ? 10 * win.u : 3 * win.u
            readonly property real insetBottom: titled ? 8 * win.u : 3 * win.u
            readonly property var at: ipc.at ?? [0, 0]
            readonly property var dims: ipc.size ?? [0, 0]
            readonly property string wsName: String(ipc.workspace?.name ?? "")
            readonly property int wsId: Number(ipc.workspace?.id ?? -9999)
            readonly property bool here: wsId === (win.monitor?.activeWorkspace?.id ?? -1)
                || (wsName !== "" && wsName === Windows.activeSpecial)
            readonly property bool shown: kindName !== "self" && addr !== "" && here
                && Number(ipc.fullscreen ?? 0) !== 2 && ipc.mapped !== false && ipc.hidden !== true
                && Number(ipc.monitor ?? -1) === (win.monitor?.id ?? -2)

            property bool settled: false

            x: at[0] - (win.monitor?.x ?? 0) - insetSide
            y: at[1] - (win.monitor?.y ?? 0) - insetTop
            width: dims[0] + 2 * insetSide
            height: dims[1] + insetTop + insetBottom
            z: 1000 - Number(ipc.focusHistoryID ?? 0)
            visible: opacity > 0
            opacity: shown ? 1 : 0

            onXChanged: Windows.kick()
            onYChanged: Windows.kick()
            onShownChanged: settleTimer.restart()

            Behavior on opacity { NumberAnimation { duration: 130 } }
            Behavior on x { enabled: frame.settled; NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on y { enabled: frame.settled; NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on width { enabled: frame.settled; NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on height { enabled: frame.settled; NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

            Timer {
                id: settleTimer
                interval: 220
                running: true
                onTriggered: frame.settled = frame.shown
            }

            Sheet {
                anchors.fill: parent
                u: win.u
                variant: frame.kindName === "terminal" ? 1 : parseInt(frame.addr.slice(-4) || "0", 16) % 3
            }

            Loader {
                anchors.fill: parent
                active: frame.titled
                sourceComponent: titleRow
            }

            Loader {
                anchors.fill: parent
                active: frame.kindName === "terminal" && Config.showDoodles
                sourceComponent: terminalArt
            }

            Loader {
                anchors.fill: parent
                active: frame.kindName === "bare" && Config.showDoodles
                sourceComponent: Component {
                    Item {
                        Tape {
                            tone: "tan"
                            x: parent.width * 0.635
                            y: -9 * win.u
                            width: 44 * win.u
                            height: 15 * win.u
                            rotation: 4
                        }
                    }
                }
            }

            Component {
                id: titleRow

                Item {
                    Rectangle {
                        x: 2 * win.u
                        y: 3 * win.u
                        width: 75 * win.u
                        height: 28 * win.u
                        color: Theme.paperDark
                        opacity: 0.65
                        radius: 3 * win.u
                    }

                    Rectangle {
                        x: 77 * win.u
                        y: 3 * win.u
                        width: Math.max(1, 0.5 * win.u)
                        height: 28 * win.u
                        color: Theme.line
                    }

                    Rectangle {
                        x: 2 * win.u
                        y: 31 * win.u
                        width: parent.width - 4 * win.u
                        height: Math.max(1, 0.5 * win.u)
                        color: Theme.line
                    }

                    Lights {
                        x: 13 * win.u
                        y: 11 * win.u
                        u: win.u
                        onCloseClicked: Windows.close(frame.addr)
                        onMinClicked: Windows.minimise(frame.addr)
                        onMaxClicked: Windows.maximise(frame.addr)
                    }

                    Hand {
                        x: 86 * win.u
                        width: parent.width - 130 * win.u
                        y: 3 * win.u
                        height: 28 * win.u
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        typed: frame.kindName === "terminal"
                        font.pixelSize: 15.2 * win.u
                        text: String(frame.ipc.title ?? "")
                        color: Theme.ink
                    }

                    IconButton {
                        x: parent.width - 29 * win.u
                        y: 5 * win.u
                        u: win.u
                        size: 12 * win.u
                        box: 22 * win.u
                        icon: "close"
                        onClicked: Windows.close(frame.addr)
                    }
                }
            }

            Component {
                id: terminalArt

                Item {
                    Tape {
                        tone: "tan"
                        x: parent.width - 54 * win.u
                        y: -6 * win.u
                        width: 48 * win.u
                        height: 15 * win.u
                        rotation: 6
                    }

                    Repeater {
                        model: frame.width > 400 * win.u ? [
                            { text: "Good", right: 83, top: 0.335 },
                            { text: "Ideas", right: 81, top: 0.44 },
                            { text: "Take", right: 80, top: 0.53 },
                            { text: "Time...", right: 78, top: 0.615 }
                        ] : []

                        Hand {
                            required property var modelData
                            x: parent.width - modelData.right * win.u
                            y: parent.height * modelData.top
                            script: true
                            text: modelData.text
                            font.pixelSize: 20 * win.u
                            color: "#5a564f"
                            rotation: -15
                            transformOrigin: Item.Left
                        }
                    }

                    Doodle {
                        visible: frame.width > 400 * win.u
                        name: "smile"
                        x: parent.width - 49 * win.u
                        y: parent.height * 0.71
                        width: 27 * win.u
                        height: 20 * win.u
                    }

                    Item {
                        x: parent.width - 98 * win.u
                        y: parent.height - 56 * win.u
                        width: 88 * win.u
                        height: 56 * win.u
                        clip: true

                        Doodle {
                            name: "cat"
                            width: 88 * win.u
                            height: 78 * win.u
                        }
                    }
                }
            }
        }
    }
}
