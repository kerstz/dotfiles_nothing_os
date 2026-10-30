import QtQuick
import ".."
import "../services"

// A themed .desktop icon, with a glyph fallback when none resolves.
Item {
    id: root
    property string appId: ""
    property real size: Theme.z.iconM
    implicitWidth: size
    implicitHeight: size

    readonly property string src: Apps.iconFor(appId)

    Image {
        id: img
        anchors.fill: parent
        source: root.src
        sourceSize.width: root.size * 2
        sourceSize.height: root.size * 2
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        visible: status === Image.Ready
        smooth: true
    }

    Glyph {
        anchors.centerIn: parent
        visible: img.status !== Image.Ready
        text: ""
        size: root.size * 0.82
        color: Theme.c.onDim
    }
}
