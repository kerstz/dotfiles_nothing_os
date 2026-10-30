import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
    id: win
    required property var modelData

    screen: modelData
    color: Theme.c.desk
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "y2k-wallpaper"
    exclusionMode: ExclusionMode.Ignore

    anchors { top: true; bottom: true; left: true; right: true }
    mask: Region {}

    Image {
        anchors.fill: parent
        source: Config.wallpaper
        fillMode: Image.PreserveAspectCrop
        cache: true
        asynchronous: true
        smooth: true
    }
}
