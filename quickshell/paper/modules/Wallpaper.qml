import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
    id: win

    required property var modelData

    screen: modelData
    color: "#2c4a6e"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "paper-wallpaper"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    mask: Region {}

    Image {
        anchors.fill: parent
        source: Config.wallpaper !== "" ? `file://${Config.wallpaper}` : Theme.asset("wallpaper.png")
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignRight
        verticalAlignment: Image.AlignBottom
        asynchronous: true
        smooth: true
        cache: true
    }
}
