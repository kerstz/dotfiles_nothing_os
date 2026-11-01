import QtQuick
import ".."

Item {
    id: root

    property real u: 2
    property alias text: input.text
    property string placeholder: ""
    property bool secret: false
    property bool multiline: false
    signal committed(string text)

    height: multiline ? 66 * u : 22 * u

    function focusField(): void {
        input.forceActiveFocus();
    }

    Rectangle {
        anchors.fill: parent
        radius: 4 * root.u
        color: Theme.paperLight
        opacity: 0.65
        border.width: Math.max(1, 0.5 * root.u)
        border.color: input.activeFocus ? Theme.ink : Theme.line
    }

    Hand {
        anchors.fill: input
        visible: input.text === ""
        verticalAlignment: root.multiline ? Text.AlignTop : Text.AlignVCenter
        text: root.placeholder
        font.pixelSize: 15 * root.u
        color: Theme.inkFaint
    }

    TextEdit {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 6 * root.u
        anchors.rightMargin: 6 * root.u
        anchors.topMargin: root.multiline ? 4 * root.u : 0
        verticalAlignment: root.multiline ? TextEdit.AlignTop : TextEdit.AlignVCenter
        wrapMode: root.multiline ? TextEdit.Wrap : TextEdit.NoWrap
        clip: true
        color: Theme.ink
        selectionColor: Theme.blueSoft
        selectByMouse: true
        font.family: Theme.ui
        font.pixelSize: 15 * root.u
        onActiveFocusChanged: {
            if (!activeFocus)
                root.committed(text);
        }
        Keys.onReturnPressed: e => {
            if (root.multiline && !(e.modifiers & Qt.ControlModifier)) {
                e.accepted = false;
                return;
            }
            root.committed(text);
        }
    }
}
