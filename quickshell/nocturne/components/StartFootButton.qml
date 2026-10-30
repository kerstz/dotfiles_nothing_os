import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    property string glyph: ""
    property string label: ""
    signal activated()

    implicitWidth: row.implicitWidth + Theme.px(22)
    implicitHeight: Theme.px(34)

    Rectangle {
        anchors.fill: parent
        radius: Theme.r.chip
        color: ma.containsMouse ? Theme.c.surface3 : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.fast } }
    }
    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(8)
        Glyph { text: root.glyph; size: Theme.z.icon; color: Theme.c.onDim }
        Text {
            text: root.label
            font.family: Theme.f.sans
            font.pixelSize: Theme.f.small
            color: Theme.c.onDim
        }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
