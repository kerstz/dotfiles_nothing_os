import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

// A taskbar button: icon, optional title, running underline and active
// fill. Left-click and close-click are signalled out to the taskbar.
Item {
    id: root

    property string pinnedId: ""
    property string appClass: ""
    property string label: ""
    property bool running: false
    property bool active: false
    property bool showLabel: false

    signal leftClick()
    signal closeClick()

    implicitHeight: Theme.z.taskBtn
    implicitWidth: showLabel
        ? Math.min(Theme.px(190), Math.max(Theme.px(44), row.implicitWidth + Theme.px(18)))
        : Theme.z.taskBtn
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: Theme.z.taskBtn
    Layout.alignment: Qt.AlignVCenter

    Rectangle {
        id: bg
        anchors.fill: parent
        anchors.topMargin: Theme.px(3)
        anchors.bottomMargin: Theme.px(3)
        radius: Theme.r.chip
        color: root.active ? Theme.tint(Theme.c.accent, 0.20)
             : (ma.containsMouse ? Theme.c.surface3 : "transparent")
        border.width: root.active ? 1 : 0
        border.color: Theme.tint(Theme.c.accent, 0.4)
        Behavior on color { ColorAnimation { duration: Theme.fast } }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(7)

        AppIcon {
            appId: root.pinnedId !== "" ? root.pinnedId : root.appClass
            size: Theme.z.iconM
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: root.showLabel && root.label !== ""
            Layout.maximumWidth: Theme.px(118)
            text: root.label
            elide: Text.ElideRight
            font.family: Theme.f.sans
            font.pixelSize: Theme.f.small
            color: root.active ? Theme.c.on : Theme.c.onDim
        }
    }

    // Running underline (icy accent).
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.px(1)
        width: root.active ? Theme.px(18) : (root.running ? Theme.px(8) : 0)
        height: Theme.px(2)
        radius: height / 2
        color: Theme.c.accent2
        Behavior on width { NumberAnimation { duration: Theme.med; easing.type: Theme.ease } }
    }

    scale: ma.pressed ? 0.94 : 1
    Behavior on scale { NumberAnimation { duration: Theme.fast; easing.type: Easing.OutQuad } }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: (m) => {
            if (m.button === Qt.MiddleButton) root.closeClick();
            else root.leftClick();
        }
    }

    Tooltip {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.top
        anchors.bottomMargin: Theme.px(6)
        text: root.label
        shown: ma.containsMouse && (!root.showLabel || root.label.length > 16)
    }
}
