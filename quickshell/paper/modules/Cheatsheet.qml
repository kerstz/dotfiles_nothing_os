import QtQuick
import ".."
import "../components"
import "../services"

OverlayPanel {
    id: win

    open: GlobalState.cheatsheetOpen
    panelWidth: 760
    panelHeight: 500
    tape: "tan"
    onDismissed: GlobalState.cheatsheetOpen = false

    Hand {
        x: 18 * win.u
        y: 10 * win.u
        script: true
        text: "Shortcuts"
        font.pixelSize: 26 * win.u
    }

    Flow {
        x: 18 * win.u
        y: 46 * win.u
        width: parent.width - 36 * win.u
        height: parent.height - 56 * win.u
        flow: Flow.TopToBottom
        spacing: 12 * win.u

        Repeater {
            model: Shortcuts.groups

            Column {
                id: group

                required property var modelData

                width: 232 * win.u

                Hand {
                    script: true
                    text: group.modelData.title
                    font.pixelSize: 17.5 * win.u
                    color: Theme.blueInk
                }

                Repeater {
                    model: group.modelData.items

                    Item {
                        id: line

                        required property var modelData

                        width: parent.width
                        height: 14.6 * win.u

                        Hand {
                            width: 112 * win.u
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            text: line.modelData[0]
                            font.pixelSize: 12.6 * win.u
                            color: Theme.ink
                            heavy: true
                        }

                        Hand {
                            x: 116 * win.u
                            width: parent.width - x
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            text: line.modelData[1]
                            font.pixelSize: 13 * win.u
                            color: Theme.inkSoft
                        }
                    }
                }
            }
        }
    }
}
