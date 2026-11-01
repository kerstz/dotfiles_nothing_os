import QtQuick
import "../.."
import "../../components"

Item {
    id: root

    property real u: 2

    Card {
        anchors.fill: parent
        u: root.u
        name: "quote"
    }

    Column {
        x: 21 * root.u
        y: 18 * root.u
        spacing: 0

        Repeater {
            model: Config.quote.split("\n")

            Hand {
                required property var modelData
                height: 20 * root.u
                verticalAlignment: Text.AlignVCenter
                text: modelData
                font.pixelSize: 16.2 * root.u
                font.letterSpacing: 0.45 * root.u
                color: Theme.inkSoft
            }
        }
    }

    Ico {
        x: 136 * root.u
        y: 83 * root.u
        size: 16 * root.u
        name: "star"
    }
}
