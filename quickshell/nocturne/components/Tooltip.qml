import QtQuick
import ".."

// A small frosted label that fades in on hover.
Item {
    id: root
    property string text: ""
    property bool shown: false

    width: bubble.width
    height: bubble.height
    visible: opacity > 0.01
    opacity: shown && text !== "" ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Theme.fast } }
    z: 100

    Frost {
        id: bubble
        width: label.implicitWidth + Theme.px(16)
        height: label.implicitHeight + Theme.px(10)
        radius: Theme.r.chip
        alpha: 0.95

        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            font.family: Theme.f.sans
            font.pixelSize: Theme.f.small
            color: Theme.c.on
        }
    }
}
