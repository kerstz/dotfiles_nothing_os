import QtQuick
import "../.."
import "../../components"
import "../../services"

Column {
    id: root

    property real u: 2

    spacing: 2 * u

    Repeater {
        model: Shortcuts.groups

        Column {
            id: group

            required property var modelData

            width: root.width

            SectionTitle { u: root.u; text: group.modelData.title }

            Repeater {
                model: group.modelData.items

                Item {
                    id: line

                    required property var modelData

                    width: parent.width
                    height: 20 * root.u

                    Hand {
                        width: parent.width * 0.5
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        heavy: true
                        text: line.modelData[0]
                        font.pixelSize: 14.5 * root.u
                    }

                    Hand {
                        x: parent.width * 0.52
                        width: parent.width * 0.46
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        text: line.modelData[1]
                        font.pixelSize: 15 * root.u
                        color: Theme.inkSoft
                    }
                }
            }
        }
    }
}
