import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import ".."
import "../components"
import "../services"

Scope {
    id: scope

    readonly property var sink: Pipewire.defaultAudioSink
    property bool armed: false

    PwObjectTracker { objects: scope.sink ? [scope.sink] : [] }

    Connections {
        target: scope.sink?.audio ?? null
        function onVolumeChanged(): void {
            if (scope.armed)
                Sys.flash("volume", scope.sink.audio.volume);
        }
        function onMutedChanged(): void {
            if (scope.armed)
                Sys.flash("volume", scope.sink.audio.muted ? 0 : scope.sink.audio.volume);
        }
    }

    Timer {
        interval: 2500
        running: true
        onTriggered: scope.armed = true
    }

    PanelWindow {
        id: win

        readonly property var targetScreen: Quickshell.screens[0]
        readonly property real u: Theme.unit(targetScreen)

        screen: targetScreen
        visible: hide.running
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "paper-osd"
        exclusionMode: ExclusionMode.Ignore
        anchors.bottom: true
        margins.bottom: 66 * u
        implicitWidth: Math.round(210 * u)
        implicitHeight: Math.round(50 * u)
        mask: Region {}

        Timer {
            id: hide
            interval: 1300
        }

        Connections {
            target: Sys
            function onOsdTickChanged(): void {
                hide.restart();
            }
        }

        Sheet {
            anchors.fill: parent
            anchors.margins: 8 * win.u
            u: win.u
            variant: 0
        }

        Ico {
            x: 20 * win.u
            y: 16 * win.u
            size: 18 * win.u
            name: Sys.osdKind === "brightness" ? "star" : (Sys.osdValue <= 0 ? "volume_mute" : "volume")
        }

        Slide {
            x: 46 * win.u
            y: 17 * win.u
            width: 124 * win.u
            u: win.u
            value: Sys.osdValue
            tone: Sys.osdKind === "brightness" ? Theme.yellow : Theme.coral
        }

        Hand {
            x: 174 * win.u
            y: 15 * win.u
            text: `${Math.round(Sys.osdValue * 100)}`
            font.pixelSize: 15 * win.u
        }
    }
}
