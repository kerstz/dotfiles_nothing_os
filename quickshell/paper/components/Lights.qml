import QtQuick
import ".."

Row {
    id: root

    property real u: 2
    signal closeClicked
    signal minClicked
    signal maxClicked

    spacing: 6.8 * u

    Repeater {
        model: [
            { tone: Theme.red, act: "close" },
            { tone: Theme.yellow, act: "min" },
            { tone: Theme.green, act: "max" }
        ]

        Rectangle {
            required property var modelData

            width: 12 * root.u
            height: width
            radius: width / 2
            color: modelData.tone
            border.width: Math.max(1, 0.4 * root.u)
            border.color: Qt.darker(modelData.tone, 1.14)

            MouseArea {
                anchors.fill: parent
                anchors.margins: -2 * root.u
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (parent.modelData.act === "close")
                        root.closeClicked();
                    else if (parent.modelData.act === "min")
                        root.minClicked();
                    else
                        root.maxClicked();
                }
            }
        }
    }
}
