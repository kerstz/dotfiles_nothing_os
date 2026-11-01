import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../services"

PanelWindow {
    id: win

    required property var modelData
    readonly property real size: Config.crosshairSize * Theme.unit(modelData)

    screen: modelData
    visible: Sys.crosshair
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "paper-crosshair"
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Math.round(size)
    implicitHeight: Math.round(size)
    mask: Region {}

    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: Math.max(2, parent.width * 0.1)
        color: Config.crosshairColor
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.max(2, parent.width * 0.1)
        height: parent.height
        color: Config.crosshairColor
    }
}
