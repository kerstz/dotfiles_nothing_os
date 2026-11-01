import QtQuick
import "../.."
import "../../components"

Item {
    id: root

    property real u: 2
    property bool adding: false

    function items(): var {
        const v = Config.todos;
        const out = [];
        if (!v)
            return out;
        for (let i = 0; i < v.length; i++)
            out.push({ text: String(v[i].text), done: Boolean(v[i].done) });
        return out;
    }

    function toggle(i: int): void {
        const list = root.items();
        list[i].done = !list[i].done;
        Config.setTodos(list);
    }

    function remove(i: int): void {
        const list = root.items();
        list.splice(i, 1);
        Config.setTodos(list);
    }

    function add(text: string): void {
        const t = text.trim();
        if (t !== "") {
            const list = root.items();
            list.push({ text: t, done: false });
            Config.setTodos(list);
        }
        root.adding = false;
    }

    Card {
        anchors.fill: parent
        u: root.u
        name: "todo"
    }

    Ico {
        x: 14 * root.u
        y: 10 * root.u
        size: 20 * root.u
        name: "checkbox"

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.adding = !root.adding;
                if (root.adding)
                    input.forceActiveFocus();
            }
        }
    }

    Hand {
        x: 46 * root.u
        y: 7 * root.u
        height: 24 * root.u
        verticalAlignment: Text.AlignVCenter
        heavy: false
        text: "Todo"
        font.pixelSize: 20 * root.u
    }

    Rectangle {
        x: 46 * root.u
        y: 29 * root.u
        width: 30 * root.u
        height: Math.max(1, 0.7 * root.u)
        color: Theme.ink
    }

    Ico {
        x: 141 * root.u
        y: 12 * root.u
        size: 15 * root.u
        name: "star_red"
    }

    Column {
        x: 14 * root.u
        y: 37 * root.u
        width: parent.width - 22 * root.u
        spacing: 0

        Repeater {
            model: root.items().slice(0, root.adding ? 4 : 5)

            Item {
                id: row

                required property var modelData
                required property int index

                width: parent.width
                height: 19.6 * root.u

                Hand {
                    id: box
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    text: row.modelData.done ? "[x]" : "[ ]"
                    font.pixelSize: 13 * root.u
                    font.letterSpacing: 0.4 * root.u
                    font.strikeout: row.modelData.done
                    color: Theme.inkSoft
                }

                Hand {
                    x: 23 * root.u
                    height: parent.height
                    width: parent.width - x
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    text: row.modelData.text
                    font.pixelSize: 15 * root.u
                    font.strikeout: row.modelData.done
                    color: Theme.inkSoft
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: e => e.button === Qt.RightButton ? root.remove(row.index) : root.toggle(row.index)
                }
            }
        }

        Item {
            visible: root.adding
            width: parent.width
            height: 19.6 * root.u

            Hand {
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                text: "[ ]"
                font.pixelSize: 13 * root.u
                font.letterSpacing: 0.4 * root.u
                color: Theme.inkSoft
            }

            TextInput {
                id: input
                x: 23 * root.u
                width: parent.width - x
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                clip: true
                color: Theme.ink
                selectionColor: Theme.blueSoft
                font.family: Theme.ui
                font.pixelSize: 15.8 * root.u
                onAccepted: {
                    root.add(text);
                    text = "";
                }
                Keys.onEscapePressed: {
                    text = "";
                    root.adding = false;
                }
            }
        }
    }
}
