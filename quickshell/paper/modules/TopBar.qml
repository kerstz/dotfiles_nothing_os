import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import ".."
import "../components"
import "../services"

PanelWindow {
    id: win

    required property var modelData
    readonly property real u: Theme.unit(modelData)
    readonly property var monitor: Hyprland.monitorFor(modelData)
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery?.isLaptopBattery ?? false
    readonly property var activeWs: monitor?.activeWorkspace ?? null
    readonly property var activeWindow: ToplevelManager.activeToplevel
    readonly property bool online: Net.online
    readonly property real iconShift: hasBattery && Config.showBattery ? 0 : 54 * u

    screen: modelData
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "paper-bar"
    anchors { top: true; left: true; right: true }
    implicitHeight: Math.round(38 * u)
    exclusionMode: ExclusionMode.Ignore
    visible: Config.showBar
    mask: Region { item: strip }

    readonly property var workspaceList: {
        const ids = [1, 2, 3, 4];
        const list = Hyprland.workspaces?.values ?? [];
        for (let i = 0; i < list.length; i++) {
            const id = list[i].id;
            if (id > 0 && ids.indexOf(id) < 0 && list[i].monitor === win.monitor)
                ids.push(id);
        }
        return ids.sort((a, b) => a - b);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    PwObjectTracker { objects: win.sink ? [win.sink] : [] }

    Item {
        id: strip
        x: 0
        y: 0
        width: parent.width
        height: 30 * win.u
    }

    Sheet {
        u: win.u
        variant: 0
        x: 3 * win.u
        y: -50 * win.u
        width: parent.width - 6 * win.u
        height: 80 * win.u
    }

    Row {
        x: 23 * win.u
        height: 30 * win.u
        spacing: 1.4 * win.u

        Repeater {
            model: win.workspaceList

            Item {
                required property var modelData
                readonly property bool active: (win.activeWs?.id ?? -1) === modelData

                width: active ? 26 * win.u : 26 * win.u
                height: parent.height

                Rectangle {
                    anchors.centerIn: parent
                    width: 25 * win.u
                    height: 20 * win.u
                    radius: 3 * win.u
                    color: Theme.blue
                    opacity: parent.active ? 0.92 : 0
                    Behavior on opacity { NumberAnimation { duration: 110 } }
                }

                Hand {
                    anchors.centerIn: parent
                    text: parent.modelData
                    font.pixelSize: 15 * win.u
                    color: Theme.ink
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = "${parent.modelData}" })`)
                }
            }
        }
    }

    Rectangle {
        x: 134 * win.u
        y: 8 * win.u
        width: Math.max(1, 0.5 * win.u)
        height: 14 * win.u
        color: Theme.line
    }

    Ico {
        x: 145 * win.u
        y: 9 * win.u
        size: 12 * win.u
        name: "terminal_small"
        visible: win.activeWindow !== null
    }

    Hand {
        x: 162 * win.u
        height: 30 * win.u
        verticalAlignment: Text.AlignVCenter
        text: Windows.label(String(win.activeWindow?.appId ?? ""))
        font.pixelSize: 14 * win.u
        color: Theme.inkSoft
    }

    Ico {
        x: win.width - 287 * win.u + win.iconShift
        y: 8 * win.u
        size: 15 * win.u
        name: "wifi"
        opacity: win.online ? 1 : 0.35

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: GlobalState.controlOpen = !GlobalState.controlOpen
        }
    }

    Ico {
        x: win.width - 258.5 * win.u + win.iconShift
        y: 8 * win.u
        size: 15 * win.u
        name: "bluetooth"
        opacity: (Bluetooth.defaultAdapter?.enabled ?? false) ? 1 : 0.35

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: GlobalState.controlOpen = !GlobalState.controlOpen
        }
    }

    Ico {
        x: win.width - 232 * win.u + win.iconShift
        y: 8 * win.u
        size: 15 * win.u
        name: (win.sink?.audio?.muted ?? false) ? "volume_mute" : "volume"

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: e => {
                if (e.button === Qt.RightButton)
                    GlobalState.openSettings("sound");
                else if (win.sink?.audio)
                    win.sink.audio.muted = !win.sink.audio.muted;
            }
            onWheel: e => {
                if (win.sink?.audio)
                    win.sink.audio.volume = Math.max(0, Math.min(1.5, win.sink.audio.volume + (e.angleDelta.y > 0 ? 0.05 : -0.05)));
            }
        }
    }

    Item {
        x: win.width - 204 * win.u
        y: 8 * win.u
        width: 15 * win.u
        height: 15 * win.u
        visible: win.hasBattery && Config.showBattery

        Ico {
            anchors.fill: parent
            size: parent.width
            name: "battery"
        }

        Rectangle {
            x: 2.2 * win.u
            y: 5 * win.u
            height: 5 * win.u
            width: 8.3 * win.u * (win.battery?.percentage ?? 0)
            radius: 0.6 * win.u
            color: Theme.ink
        }
    }

    Hand {
        x: win.width - 186 * win.u
        height: 30 * win.u
        verticalAlignment: Text.AlignVCenter
        visible: win.hasBattery && Config.showBattery
        text: `${Math.round((win.battery?.percentage ?? 0) * 100)}%`
        font.pixelSize: 14 * win.u
        color: Theme.inkSoft
    }

    Hand {
        anchors.right: time.left
        anchors.rightMargin: 12 * win.u
        height: 30 * win.u
        verticalAlignment: Text.AlignVCenter
        text: clock.date.toLocaleString(Config.locale, "ddd, d MMM")
        font.pixelSize: 14 * win.u
        color: Theme.inkSoft

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: GlobalState.notifOpen = !GlobalState.notifOpen
        }
    }

    Hand {
        id: time
        anchors.right: parent.right
        anchors.rightMargin: 23 * win.u
        height: 30 * win.u
        verticalAlignment: Text.AlignVCenter
        text: Config.clock24 ? clock.date.toLocaleString(Config.locale, "HH:mm") : clock.date.toLocaleString(Config.locale, "h:mm AP").toUpperCase()
        font.pixelSize: 14 * win.u
        color: Theme.inkSoft

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: GlobalState.controlOpen = !GlobalState.controlOpen
        }
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 296 * win.u - win.iconShift
        height: 30 * win.u
        spacing: 7 * win.u
        visible: Config.showTray

        Repeater {
            model: SystemTray.items

            Image {
                id: trayIcon

                required property var modelData

                anchors.verticalCenter: parent.verticalCenter
                width: 13 * win.u
                height: 13 * win.u
                source: modelData.icon
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true

                QsMenuAnchor {
                    id: trayMenu
                    menu: trayIcon.modelData.menu
                    anchor.window: win
                    anchor.rect.x: trayIcon.x
                    anchor.rect.y: win.u * 28
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: e => {
                        if (e.button === Qt.RightButton && trayIcon.modelData.hasMenu)
                            trayMenu.open();
                        else if (e.button === Qt.MiddleButton)
                            trayIcon.modelData.secondaryActivate();
                        else
                            trayIcon.modelData.activate();
                    }
                }
            }
        }
    }

    Rectangle {
        visible: Sys.recording
        x: 215 * win.u
        y: 11 * win.u
        width: 8 * win.u
        height: width
        radius: width / 2
        color: Theme.red
    }
}
