import QtQuick
import ".."

Item {
    id: root

    property real u: 2
    property string label: ""
    property string hint: ""
    default property alias control: slot.data

    width: parent ? parent.width : 300 * u
    height: Math.max(26 * u, text.implicitHeight + 8 * u)

    Column {
        id: text
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - slot.width - 10 * root.u

        Hand {
            width: parent.width
            wrapMode: Text.WordWrap
            text: root.label
            font.pixelSize: 16 * root.u
        }

        Hand {
            visible: root.hint !== ""
            width: parent.width
            wrapMode: Text.WordWrap
            text: root.hint
            font.pixelSize: 13.5 * root.u
            color: Theme.inkFaint
        }
    }

    Item {
        id: slot
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }
}
