import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

PanelWindow {
    id: win

    required property var modelData
    readonly property real u: Theme.unit(modelData)

    screen: modelData
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "paper-dock"
    anchors.bottom: true
    implicitWidth: Math.round(Math.max(500, 74 + 53.2 * (Config.dockApps.length - 1)) * u)
    implicitHeight: Math.round(62 * u)
    exclusionMode: ExclusionMode.Ignore
    visible: Config.showDock
    mask: Region { item: body }

    function launch(app: var): void {
        if (app.action === "trash") {
            GlobalState.openFiles(Config.trash);
            return;
        }
        if (app.action === "files") {
            GlobalState.filesOpen = true;
            const files = Windows.find("org.quickshell");
            if (files)
                Windows.restore(files);
            return;
        }
        const running = Windows.find(app.cls ?? "");
        if (running) {
            Windows.restore(running);
            return;
        }
        if (app.entry) {
            app.entry.execute();
            return;
        }
        Quickshell.execDetached(["sh", "-c", app.cmd]);
    }

    Item {
        id: body
        x: 10 * win.u
        y: 14 * win.u
        width: parent.width - 20 * win.u
        height: 48 * win.u

        Image {
            x: -14 * win.u
            y: -14 * win.u
            width: parent.width + 28 * win.u
            height: 89 * win.u
            source: Theme.asset("paper/dock.png")
            smooth: true
            mipmap: true
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -1.5 * win.u
            y: 11 * win.u

            Repeater {
                model: Config.dockApps

                Item {
                    id: slot

                    required property var modelData
                    readonly property bool isSep: modelData.separator === true

                    width: isSep ? 36 * win.u : 53.2 * win.u
                    height: 26 * win.u

                    Rectangle {
                        visible: slot.isSep
                        x: 10 * win.u
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.max(1, 0.5 * win.u)
                        height: 25 * win.u
                        color: Theme.inkSoft
                    }

                    Ico {
                        id: glyph
                        visible: !slot.isSep
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: mouse.containsMouse ? -2.5 * win.u : 0
                        size: 26 * win.u
                        name: slot.modelData.icon ?? ""
                        source: slot.modelData.iconPath ? slot.modelData.iconPath : (name === "" ? "" : Theme.icon(name))
                        Behavior on y { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        id: mouse
                        visible: !slot.isSep
                        anchors.fill: parent
                        anchors.margins: -5 * win.u
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: win.launch(slot.modelData)
                    }
                }
            }
        }
    }
}
