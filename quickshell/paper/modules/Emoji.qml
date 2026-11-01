import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../components"

OverlayPanel {
    id: win

    property var all: []
    property string query: ""

    readonly property var shown: {
        const q = win.query.toLowerCase();
        return q === "" ? win.all : win.all.filter(e => e.k.indexOf(q) >= 0);
    }

    open: GlobalState.emojiOpen
    panelWidth: 340
    panelHeight: 320
    tape: "pink"
    onDismissed: GlobalState.emojiOpen = false

    onVisibleChanged: {
        if (visible) {
            win.query = "";
            search.text = "";
            search.forceActiveFocus();
        }
    }

    function pick(e: var): void {
        if (!e)
            return;
        Quickshell.execDetached(["wl-copy", e.e]);
        GlobalState.emojiOpen = false;
    }

    FileView {
        path: Qt.resolvedUrl("../assets/emoji.json")
        preload: true
        onLoaded: win.all = JSON.parse(text())
    }

    Ico {
        x: 16 * win.u
        y: 18 * win.u
        size: 14 * win.u
        name: "search"
    }

    TextInput {
        id: search
        x: 38 * win.u
        y: 13 * win.u
        width: parent.width - 54 * win.u
        height: 24 * win.u
        verticalAlignment: TextInput.AlignVCenter
        clip: true
        color: Theme.ink
        selectionColor: Theme.blueSoft
        font.family: Theme.ui
        font.pixelSize: 18 * win.u
        onTextChanged: win.query = text
        Keys.onEscapePressed: GlobalState.emojiOpen = false
        Keys.onReturnPressed: win.pick(win.shown[0])
    }

    Rectangle {
        x: 14 * win.u
        y: 40 * win.u
        width: parent.width - 28 * win.u
        height: Math.max(1, 0.6 * win.u)
        color: Theme.line
    }

    GridView {
        x: 12 * win.u
        y: 45 * win.u
        width: parent.width - 24 * win.u
        height: parent.height - 55 * win.u
        clip: true
        cellWidth: width / 9
        cellHeight: cellWidth
        boundsBehavior: Flickable.StopAtBounds
        model: win.shown

        delegate: Item {
            id: cell

            required property var modelData

            width: GridView.view.cellWidth
            height: GridView.view.cellHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1 * win.u
                radius: 5 * win.u
                color: Theme.blueSoft
                opacity: mouse.containsMouse ? 0.8 : 0
            }

            Text {
                anchors.centerIn: parent
                text: cell.modelData.e
                font.pixelSize: 19 * win.u
                textFormat: Text.PlainText
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: win.pick(cell.modelData)
            }
        }
    }
}
