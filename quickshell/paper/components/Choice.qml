import QtQuick
import ".."

Row {
    id: root

    property real u: 2
    property var options: []
    property var value
    signal picked(var value)

    spacing: 4 * u

    Repeater {
        model: root.options

        Item {
            id: opt

            required property var modelData
            readonly property bool active: root.value === modelData.value

            width: label.implicitWidth + 13 * root.u
            height: 21 * root.u

            Rectangle {
                anchors.fill: parent
                radius: 4 * root.u
                color: Theme.blueSoft
                opacity: opt.active ? 0.95 : (hover.containsMouse ? 0.4 : 0)
                border.width: opt.active ? Math.max(1, 0.5 * root.u) : 0
                border.color: Theme.inkSoft
            }

            Hand {
                id: label
                anchors.centerIn: parent
                text: opt.modelData.label
                font.pixelSize: 15 * root.u
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.picked(opt.modelData.value)
            }
        }
    }
}
