import QtQuick
import ".."

Item {
    id: root

    property string icon: ""
    property real u: 2
    property real size: 16 * u
    property real box: size + 8 * u
    signal clicked
    signal rightClicked

    width: box
    height: box

    Rectangle {
        anchors.fill: parent
        radius: 4 * root.u
        color: Theme.paperDeep
        opacity: mouse.containsMouse ? 0.55 : 0
        Behavior on opacity { NumberAnimation { duration: 90 } }
    }

    Ico {
        anchors.centerIn: parent
        name: root.icon
        size: root.size
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: e => e.button === Qt.RightButton ? root.rightClicked() : root.clicked()
    }
}
