import QtQuick
import ".."

// Tiled phosphor scanlines + a soft vignette + an optional flicker.
Item {
    id: root
    property bool vignette: true
    property bool flicker: Config.crtFlicker
    property real intensity: 1.0

    Image {
        anchors.fill: parent
        source: Config.scanlines
        fillMode: Image.Tile
        smooth: false
        opacity: 0.5 * root.intensity
    }

    Image {
        visible: root.vignette
        anchors.fill: parent
        source: Config.vignette
        fillMode: Image.Stretch
        smooth: true
        opacity: 0.9 * root.intensity
    }

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        opacity: 0.0
        SequentialAnimation on opacity {
            running: root.flicker
            loops: Animation.Infinite
            NumberAnimation { to: 0.03; duration: 70 }
            NumberAnimation { to: 0.0;  duration: 50 }
            NumberAnimation { to: 0.015; duration: 110 }
            NumberAnimation { to: 0.0;  duration: 900 }
        }
    }
}
