import QtQuick
import ".."

Item {
    id: root

    property real u: 2
    property string name: "quote"

    readonly property real pad: 14 * u

    Image {
        x: -root.pad
        y: -root.pad
        width: root.width + 2 * root.pad
        height: root.height + 2 * root.pad
        source: Theme.asset(`paper/card_${root.name}.png`)
        smooth: true
        mipmap: true
        cache: true
    }
}
