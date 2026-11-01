import QtQuick
import ".."
import "../components"
import "../services"

OverlayPanel {
    id: win

    open: GlobalState.wallpaperOpen
    panelWidth: 560
    panelHeight: 370
    tape: "blue"
    onDismissed: GlobalState.wallpaperOpen = false

    Hand {
        x: 18 * win.u
        y: 10 * win.u
        script: true
        text: "Wallpaper"
        font.pixelSize: 24 * win.u
    }

    Hand {
        x: 130 * win.u
        y: 17 * win.u
        width: parent.width - 190 * win.u
        elide: Text.ElideMiddle
        text: Wall.folderPath
        font.pixelSize: 14 * win.u
        color: Theme.inkFaint
    }

    GridView {
        id: grid
        x: 14 * win.u
        y: 46 * win.u
        width: parent.width - 28 * win.u
        height: parent.height - 56 * win.u
        clip: true
        cellWidth: width / 3
        cellHeight: cellWidth * 0.66
        boundsBehavior: Flickable.StopAtBounds
        model: win.visible ? Wall.items : []

        delegate: Item {
            id: cell

            required property var modelData
            readonly property bool active: Config.wallpaper === modelData.path

            width: grid.cellWidth
            height: grid.cellHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: 3 * win.u
                color: Theme.paperLight
                border.width: cell.active ? Math.max(2, 1 * win.u) : Math.max(1, 0.4 * win.u)
                border.color: cell.active ? Theme.blueInk : Theme.line
            }

            Image {
                anchors.fill: parent
                anchors.margins: 6 * win.u
                source: cell.modelData.path === "" ? Wall.bundled : `file://${cell.modelData.path}`
                sourceSize.width: 420
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                clip: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Wall.set(cell.modelData.path)
            }
        }
    }
}
