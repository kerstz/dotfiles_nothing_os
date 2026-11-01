import QtQuick
import ".."

Item {
    id: root

    property real u: 2
    property string label: ""
    property string icon: ""
    property color tone: Theme.paperDark
    signal clicked

    width: row.implicitWidth + 14 * u
    height: 22 * u

    Rectangle {
        anchors.fill: parent
        radius: 4 * root.u
        color: mouse.containsMouse ? Theme.blueSoft : root.tone
        border.width: Math.max(1, 0.5 * root.u)
        border.color: Theme.inkSoft
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4 * root.u

        Ico {
            visible: root.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
            size: 12 * root.u
            name: root.icon
        }

        Hand {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            font.pixelSize: 15 * root.u
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
