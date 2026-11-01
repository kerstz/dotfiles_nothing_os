import QtQuick
import ".."

Item {
    id: root

    property real u: 2
    property int variant: 0

    readonly property real k: u / 2
    readonly property real pad: 28 * k

    BorderImage {
        x: -root.pad
        y: -root.pad
        width: (root.width + 2 * root.pad) / root.k
        height: (root.height + 2 * root.pad) / root.k
        scale: root.k
        transformOrigin: Item.TopLeft
        source: Theme.asset(`paper/sheet_${root.variant}.png`)
        border { left: 104; right: 104; top: 104; bottom: 104 }
        horizontalTileMode: BorderImage.Round
        verticalTileMode: BorderImage.Round
        smooth: true
        cache: true
    }
}
