import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"

// Full-screen CRT flourish. Overlay layer, fully click-through.
PanelWindow {
    id: win
    required property var modelData

    screen: modelData
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "y2k-crt"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    mask: Region {}

    Scanlines { anchors.fill: parent }
}
