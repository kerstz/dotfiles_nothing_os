import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

Scope {
    id: root

    required property var modelData
    readonly property real u: Theme.unit(modelData)

    PanelWindow {
        screen: root.modelData
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "paper-reserve"
        anchors { top: true; bottom: true; right: true }
        implicitWidth: 1
        exclusiveZone: Math.round(190 * root.u)
        mask: Region {}
    }

    PanelWindow {
        visible: Config.showBar
        screen: root.modelData
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "paper-reserve"
        anchors { top: true; left: true; right: true }
        implicitHeight: 1
        exclusiveZone: Math.round(30 * root.u)
        mask: Region {}
    }

    PanelWindow {
        visible: Config.showDock
        screen: root.modelData
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "paper-reserve"
        anchors { bottom: true; left: true; right: true }
        implicitHeight: 1
        exclusiveZone: Math.round(48 * root.u)
        mask: Region {}
    }
}
