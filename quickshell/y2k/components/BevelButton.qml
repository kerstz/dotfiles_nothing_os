import QtQuick
import ".."

Item {
    id: root

    property string text: ""
    property color face: Theme.c.face
    property color textColor: Theme.c.ink
    property string fontFamily: Theme.f.display
    property int fontSize: Theme.f.small
    property bool active: false        // held sunken (e.g. focused task)
    property int depth: Theme.edge
    property bool bold: false

    default property alias content: slot.data

    signal clicked()
    signal rightClicked()

    implicitWidth: label.implicitWidth + Theme.px(22)
    implicitHeight: Theme.z.row

    readonly property bool down: ma.pressed || root.active

    Bevel {
        anchors.fill: parent
        face: root.face
        depth: root.depth
        raised: !root.down

        Item {
            id: slot
            anchors.fill: parent
            // Push the content in on press, as a real key would.
            anchors.leftMargin: root.down ? Theme.px(1) : 0
            anchors.topMargin: root.down ? Theme.px(1) : 0
        }

        Text {
            id: label
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.down ? Theme.px(1) : 0
            anchors.verticalCenterOffset: root.down ? Theme.px(1) : 0
            visible: root.text !== ""
            text: root.text
            color: root.textColor
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            font.bold: root.bold
            renderType: Text.NativeRendering
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (m) => {
            if (m.button === Qt.RightButton) root.rightClicked();
            else root.clicked();
        }
    }
}
