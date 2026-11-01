import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import ".."

PanelWindow {
    id: win

    required property var modelData
    property bool open: false
    property real panelWidth: 300
    property real panelHeight: 300
    property real panelX: -1
    property real panelY: -1
    property string tape: "tan"
    property bool dim: true
    default property alias content: body.data
    signal dismissed

    readonly property real u: Theme.unit(modelData)
    readonly property bool focused: Hyprland.focusedMonitor?.name === modelData.name
    readonly property Item panel: panelItem

    screen: modelData
    visible: open && focused
    color: dim ? "#33000000" : "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "paper-overlay"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }

    MouseArea {
        anchors.fill: parent
        onClicked: win.dismissed()
    }

    Item {
        id: panelItem
        x: win.panelX >= 0 ? win.panelX * win.u : (parent.width - width) / 2
        y: win.panelY >= 0 ? win.panelY * win.u : (parent.height - height) / 2
        width: win.panelWidth * win.u
        height: win.panelHeight * win.u

        MouseArea { anchors.fill: parent }

        Sheet {
            anchors.fill: parent
            u: win.u
            variant: 1
        }

        Tape {
            visible: win.tape !== ""
            tone: win.tape === "" ? "tan" : win.tape
            x: parent.width - 62 * win.u
            y: -7 * win.u
            width: 48 * win.u
            height: 16 * win.u
            rotation: 5
        }

        Item {
            id: body
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: win.dismissed()
        }
    }
}
