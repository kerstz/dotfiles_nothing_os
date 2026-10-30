import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

// The wallpaper, one layer-surface per screen at the bottom. A violet
// scrim deepens the gradient so panels and text sit on true night.
PanelWindow {
    id: win
    required property var modelData

    screen: modelData
    color: Theme.c.bg
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "nocturne-bg"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }

    readonly property string wall: Config.wallpaper !== ""
        ? (Config.wallpaper.startsWith("/") ? "file://" + Config.wallpaper : Config.wallpaper)
        : "file://" + Quickshell.shellPath("../../hypr/wallpapers/nocturne.png")

    Image {
        anchors.fill: parent
        source: Config.drawWallpaper ? win.wall : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: status === Image.Ready
    }

    // A cold violet vignette, darker at the edges.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.04, 0.02, 0.10, 0.18) }
            GradientStop { position: 0.6; color: Qt.rgba(0.02, 0.01, 0.06, 0.28) }
            GradientStop { position: 1.0; color: Qt.rgba(0.01, 0.00, 0.04, 0.5) }
        }
    }
}
