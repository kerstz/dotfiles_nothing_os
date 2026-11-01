import QtQuick
import "../.."
import "../../components"

Item {
    id: root

    property real u: 2

    Card {
        anchors.fill: parent
        u: root.u
        name: "photo"
    }

    Image {
        x: 10 * root.u
        y: 7 * root.u
        width: 93 * root.u
        height: 77 * root.u
        source: Config.photo !== "" ? `file://${Config.photo}` : Theme.asset("photo.png")
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
    }

    Tape {
        tone: "tan"
        x: -9 * root.u
        y: -3 * root.u
        width: 37 * root.u
        height: 21 * root.u
        rotation: -62
    }

    Column {
        x: 106 * root.u
        y: 15 * root.u
        width: 62 * root.u
        spacing: 0

        Repeater {
            model: Config.photoCaption.split("\n")

            Hand {
                required property var modelData
                width: parent.width
                height: 16 * root.u
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                script: true
                text: modelData
                font.pixelSize: 14.5 * root.u
                color: Theme.inkSoft
            }
        }
    }
}
