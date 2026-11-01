import QtQuick
import ".."
import "../components"

OverlayPanel {
    id: win

    readonly property var notes: {
        const v = Config.notes;
        const out = [];
        if (!v)
            return out;
        for (let i = 0; i < v.length; i++)
            out.push({ text: String(v[i].text) });
        return out;
    }

    open: GlobalState.notesOpen
    panelWidth: 620
    panelHeight: 420
    tape: "pink"
    onDismissed: GlobalState.notesOpen = false

    function update(i: int, text: string): void {
        const list = win.notes.slice();
        if (i < list.length && list[i].text !== text) {
            list[i] = { text: text };
            Config.setNotes(list);
        }
    }

    function remove(i: int): void {
        const list = win.notes.slice();
        list.splice(i, 1);
        Config.setNotes(list);
    }

    function add(): void {
        Config.setNotes(win.notes.concat([{ text: "" }]));
    }

    Hand {
        x: 18 * win.u
        y: 10 * win.u
        script: true
        text: "Notes"
        font.pixelSize: 25 * win.u
    }

    PaperButton {
        anchors.right: parent.right
        anchors.rightMargin: 70 * win.u
        y: 13 * win.u
        u: win.u
        label: "New note"
        icon: "plus"
        onClicked: win.add()
    }

    GridView {
        id: grid
        x: 14 * win.u
        y: 46 * win.u
        width: parent.width - 28 * win.u
        height: parent.height - 56 * win.u
        clip: true
        cellWidth: width / 3
        cellHeight: 170 * win.u
        boundsBehavior: Flickable.StopAtBounds
        model: win.notes.length

        delegate: Item {
            id: cell

            required property int index

            width: grid.cellWidth
            height: grid.cellHeight
            rotation: (index % 3 - 1) * 0.8

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6 * win.u
                color: index % 2 ? "#f0e5c8" : "#efe5d5"
                border.width: Math.max(1, 0.4 * win.u)
                border.color: Theme.line
            }

            Tape {
                tone: cell.index % 2 ? "blue" : "tan"
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                width: 44 * win.u
                height: 13 * win.u
                rotation: -3
            }

            TextEdit {
                anchors.fill: parent
                anchors.margins: 14 * win.u
                wrapMode: TextEdit.Wrap
                color: Theme.ink
                selectionColor: Theme.blueSoft
                selectByMouse: true
                font.family: Theme.script
                font.pixelSize: 15.5 * win.u
                text: win.notes[cell.index]?.text ?? ""
                onActiveFocusChanged: {
                    if (!activeFocus)
                        win.update(cell.index, text);
                }
            }

            IconButton {
                x: parent.width - 27 * win.u
                y: 9 * win.u
                u: win.u
                size: 8 * win.u
                box: 17 * win.u
                icon: "close"
                onClicked: win.remove(cell.index)
            }
        }
    }
}
