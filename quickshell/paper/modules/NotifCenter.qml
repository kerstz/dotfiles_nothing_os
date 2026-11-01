import QtQuick
import ".."
import "../components"
import "../services"

OverlayPanel {
    id: win

    open: GlobalState.notifOpen
    dim: false
    panelWidth: 300
    panelHeight: 400
    panelX: modelData.width / u - 306
    panelY: 34
    tape: "pink"
    onDismissed: GlobalState.notifOpen = false

    Hand {
        x: 16 * win.u
        y: 11 * win.u
        script: true
        text: "Notifications"
        font.pixelSize: 21 * win.u
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 14 * win.u
        y: 12 * win.u
        spacing: 7 * win.u

        Hand {
            anchors.verticalCenter: parent.verticalCenter
            text: "Quiet"
            font.pixelSize: 15 * win.u
            color: Theme.inkSoft
        }

        Toggle {
            anchors.verticalCenter: parent.verticalCenter
            u: win.u
            checked: Config.dnd
            onToggled: v => Config.set("dnd", v)
        }

        PaperButton {
            u: win.u
            label: "Clear"
            onClicked: Notifs.clearAll()
        }
    }

    ListView {
        id: list
        x: 12 * win.u
        y: 42 * win.u
        width: parent.width - 24 * win.u
        height: parent.height - 52 * win.u
        clip: true
        spacing: 5 * win.u
        boundsBehavior: Flickable.StopAtBounds
        model: Notifs.history

        delegate: Item {
            id: entry

            required property var modelData

            width: list.width
            height: bodyText.y + bodyText.implicitHeight + 8 * win.u

            Rectangle {
                anchors.fill: parent
                radius: 5 * win.u
                color: Theme.paperLight
                opacity: 0.7
                border.width: Math.max(1, 0.4 * win.u)
                border.color: Theme.line
            }

            Hand {
                x: 8 * win.u
                y: 5 * win.u
                width: parent.width - 40 * win.u
                elide: Text.ElideRight
                text: entry.modelData.summary || entry.modelData.appName
                font.pixelSize: 15.5 * win.u
                heavy: true
            }

            Hand {
                id: bodyText
                x: 8 * win.u
                y: 22 * win.u
                width: parent.width - 16 * win.u
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
                text: entry.modelData.body
                font.pixelSize: 14.5 * win.u
                color: Theme.inkSoft
            }

            IconButton {
                x: parent.width - 21 * win.u
                y: 2 * win.u
                u: win.u
                size: 8 * win.u
                box: 18 * win.u
                icon: "close"
                onClicked: Notifs.dismiss(entry.modelData.source)
            }
        }

        Hand {
            anchors.centerIn: parent
            visible: Notifs.history.length === 0
            script: true
            text: "All quiet..."
            font.pixelSize: 20 * win.u
            color: Theme.inkFaint
        }
    }
}
