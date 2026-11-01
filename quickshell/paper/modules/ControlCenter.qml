import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import ".."
import "../components"
import "../services"

OverlayPanel {
    id: win

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    open: GlobalState.controlOpen
    dim: false
    panelWidth: 300
    panelHeight: 306
    panelX: modelData.width / u - 306
    panelY: 34
    tape: "blue"
    onDismissed: GlobalState.controlOpen = false

    onVisibleChanged: if (visible) Net.refresh()

    PwObjectTracker { objects: [win.sink, win.source].filter(o => o) }

    readonly property var tiles: [
        { label: "Wi-Fi", icon: "wifi", on: Net.wifiOn, act: () => Net.setWifi(!Net.wifiOn), more: "network", sub: Net.active },
        { label: "Bluetooth", icon: "bluetooth", on: Bluetooth.defaultAdapter?.enabled ?? false, act: () => { if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled; }, more: "network", sub: "" },
        { label: "Mute", icon: "volume_mute", on: win.sink?.audio?.muted ?? false, act: () => { if (win.sink?.audio) win.sink.audio.muted = !win.sink.audio.muted; }, more: "sound", sub: "" },
        { label: "Mic off", icon: "volume_mute", on: win.source?.audio?.muted ?? false, act: () => { if (win.source?.audio) win.source.audio.muted = !win.source.audio.muted; }, more: "sound", sub: "" },
        { label: "Night", icon: "star", on: Sys.night, act: () => Sys.setNight(!Sys.night), more: "screen", sub: "" },
        { label: "Awake", icon: "lock", on: Sys.caffeine, act: () => Sys.setCaffeine(!Sys.caffeine), more: "screen", sub: "" },
        { label: "Quiet", icon: "bell", on: Config.dnd, act: () => Config.set("dnd", !Config.dnd), more: "", sub: "" },
        { label: "Game", icon: "gear", on: Sys.game, act: () => Sys.setGame(!Sys.game), more: "game", sub: "" },
        { label: "Record", icon: "video", on: Sys.recording, act: () => { GlobalState.controlOpen = false; Sys.record("screen", "none"); }, more: "", sub: "" },
        { label: "Shot", icon: "image", on: false, act: () => { GlobalState.controlOpen = false; Sys.screenshot("region", "copy"); }, more: "", sub: "" },
        { label: "Notes", icon: "document", on: false, act: () => { GlobalState.controlOpen = false; GlobalState.notesOpen = true; }, more: "", sub: "" },
        { label: "Settings", icon: "gear", on: false, act: () => { GlobalState.controlOpen = false; GlobalState.openSettings(""); }, more: "", sub: "" }
    ]

    Grid {
        x: 14 * win.u
        y: 14 * win.u
        columns: 4
        spacing: 5 * win.u

        Repeater {
            model: win.tiles

            Item {
                id: tile

                required property var modelData

                width: 64 * win.u
                height: 54 * win.u

                Rectangle {
                    anchors.fill: parent
                    radius: 6 * win.u
                    color: tile.modelData.on ? Theme.blueSoft : (mouse.containsMouse ? Theme.paperDark : "transparent")
                    border.width: Math.max(1, 0.5 * win.u)
                    border.color: tile.modelData.on ? Theme.inkSoft : Theme.line
                }

                Ico {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 7 * win.u
                    size: 21 * win.u
                    name: tile.modelData.icon
                }

                Hand {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 30 * win.u
                    text: tile.modelData.label
                    font.pixelSize: 14.5 * win.u
                    color: Theme.inkSoft
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: e => {
                        if (e.button === Qt.RightButton && tile.modelData.more !== "") {
                            GlobalState.controlOpen = false;
                            GlobalState.openSettings(tile.modelData.more);
                        } else {
                            tile.modelData.act();
                        }
                    }
                }
            }
        }
    }

    Ico {
        x: 16 * win.u
        y: 196 * win.u
        size: 16 * win.u
        name: (win.sink?.audio?.muted ?? false) ? "volume_mute" : "volume"
    }

    Slide {
        x: 40 * win.u
        y: 196 * win.u
        width: parent.width - 54 * win.u
        u: win.u
        value: win.sink?.audio?.volume ?? 0
        onMoved: v => {
            if (win.sink?.audio)
                win.sink.audio.volume = v;
        }
    }

    Ico {
        x: 16 * win.u
        y: 221 * win.u
        size: 16 * win.u
        name: "star"
        visible: Sys.backlightKind !== ""
    }

    Slide {
        x: 40 * win.u
        y: 221 * win.u
        width: parent.width - 54 * win.u
        u: win.u
        visible: Sys.backlightKind !== ""
        value: Sys.brightness
        tone: Theme.yellow
        onMoved: v => Sys.setBrightness(v)
    }

    Rectangle {
        x: 14 * win.u
        y: 246 * win.u
        width: parent.width - 28 * win.u
        height: Math.max(1, 0.5 * win.u)
        color: Theme.line
    }

    Row {
        x: 14 * win.u
        y: 255 * win.u
        spacing: 7 * win.u

        PaperButton { u: win.u; label: "Lock"; icon: "lock"; onClicked: { GlobalState.controlOpen = false; Lock.activate(); } }
        PaperButton { u: win.u; label: "Notifications"; icon: "bell"; onClicked: { GlobalState.controlOpen = false; GlobalState.notifOpen = true; } }
        PaperButton { u: win.u; label: "Power"; icon: "power"; onClicked: { GlobalState.controlOpen = false; GlobalState.sessionOpen = true; } }
    }
}
