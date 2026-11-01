import QtQuick
import ".."

Item {
    id: root

    property real u: 2
    property real value: 0
    property color tone: Theme.coral
    signal moved(real value)

    height: 16 * u

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 2.4 * root.u
        radius: height / 2
        color: "#c9c1b3"

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: height / 2
            color: root.tone
        }
    }

    Rectangle {
        x: (parent.width - width) * Math.max(0, Math.min(1, root.value))
        anchors.verticalCenter: parent.verticalCenter
        width: 8 * root.u
        height: width
        radius: width / 2
        color: root.tone
        border.width: Math.max(1, 0.5 * root.u)
        border.color: Qt.darker(root.tone, 1.3)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: e => root.moved(Math.max(0, Math.min(1, e.x / width)))
        onPositionChanged: e => {
            if (pressed)
                root.moved(Math.max(0, Math.min(1, e.x / width)));
        }
    }
}
