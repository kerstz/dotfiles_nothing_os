import QtQuick
import ".."

Item {
    id: root

    property real u: 2
    property bool checked: false
    signal toggled(bool value)

    width: 32 * u
    height: 17 * u

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.blue : Theme.paperLight
        border.width: Math.max(1, 0.7 * root.u)
        border.color: Theme.ink
        Behavior on color { ColorAnimation { duration: 110 } }
    }

    Rectangle {
        y: 3.5 * root.u
        x: root.checked ? parent.width - width - 3.5 * root.u : 3.5 * root.u
        width: 10 * root.u
        height: width
        radius: width / 2
        color: Theme.ink
        Behavior on x { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
