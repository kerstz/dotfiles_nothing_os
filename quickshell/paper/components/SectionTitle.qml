import QtQuick
import ".."

Item {
    id: root

    property real u: 2
    property string text: ""

    width: parent ? parent.width : 300 * u
    height: 30 * u

    Hand {
        y: 2 * root.u
        script: true
        text: root.text
        font.pixelSize: 21 * root.u
    }

    Rectangle {
        y: 27 * root.u
        width: parent.width
        height: Math.max(1, 0.5 * root.u)
        color: Theme.line
    }
}
