import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import ".."
import "../components"

PanelWindow {
    id: win
    required property var modelData

    screen: modelData
    readonly property bool onFocusedMonitor:
        (Hyprland.focusedMonitor?.name ?? "") === (win.modelData?.name ?? "")
    color: "transparent"
    visible: GlobalState.startOpen && onFocusedMonitor

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "y2k-start"
    WlrLayershell.keyboardFocus: win.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: menu }

    readonly property var apps: {
        const all = DesktopEntries.applications?.values ?? [];
        const q = search.text.toLowerCase();
        const out = [];
        for (let i = 0; i < all.length; i++) {
            const e = all[i];
            if (e.noDisplay) continue;
            if (q !== "" && !String(e.name).toLowerCase().includes(q)) continue;
            out.push(e);
        }
        out.sort((a, b) => String(a.name).localeCompare(String(b.name)));
        return out;
    }

    function launch(entry: var): void {
        if (!entry) return;
        entry.execute();
        GlobalState.startOpen = false;
    }
    function run(cmd: string): void {
        Quickshell.execDetached(["sh", "-c", cmd]);
        GlobalState.startOpen = false;
    }

    onVisibleChanged: if (visible) { search.text = ""; search.forceActiveFocus(); }

    HyprlandFocusGrab {
        active: win.visible
        windows: [win]
        onCleared: GlobalState.startOpen = false
    }

    Bevel {
        id: menu
        width: Theme.z.bannerW + Theme.z.menuW
        height: Theme.px(400)
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: Theme.px(4)
        anchors.bottomMargin: Theme.z.taskbar + Theme.px(4)
        raised: true
        face: Theme.c.face

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ── Chrome side banner ────────────────────────────────────
            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: Theme.z.bannerW
                clip: true

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: Theme.c.blue }
                        GradientStop { position: 0.5; color: Theme.c.violet }
                        GradientStop { position: 1.0; color: Theme.c.pink }
                    }
                }
                // Faint scanline wash over the banner for the CRT feel.
                Scanlines { anchors.fill: parent; vignette: false; flicker: false; intensity: 0.7 }

                Text {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Theme.px(14)
                    anchors.horizontalCenter: parent.horizontalCenter
                    rotation: -90
                    transformOrigin: Item.Center
                    text: "Y2K  ·  MILLENNIUM"
                    color: "#ffffff"
                    font.family: Theme.f.arcade
                    font.pixelSize: Theme.f.small
                    renderType: Text.NativeRendering
                }
            }

            // ── Content ───────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: Theme.px(6)
                spacing: Theme.px(6)

                // Search well
                Bevel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.z.row
                    raised: false
                    face: "#ffffff"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.px(6)
                        anchors.rightMargin: Theme.px(6)
                        spacing: Theme.px(6)

                        Text {
                            text: "⌕"
                            color: Theme.c.inkDim
                            font.family: Theme.f.mono
                            font.pixelSize: Theme.f.body
                        }
                        TextInput {
                            id: search
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            color: Theme.c.ink
                            font.family: Theme.f.display
                            font.pixelSize: Theme.f.small
                            clip: true
                            Keys.onEscapePressed: GlobalState.startOpen = false
                            Keys.onReturnPressed: win.launch(win.apps[0] ?? null)
                            Keys.onEnterPressed: win.launch(win.apps[0] ?? null)

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: search.text === ""
                                text: "Run programs..."
                                color: Theme.c.inkDim
                                font.family: Theme.f.display
                                font.pixelSize: Theme.f.small
                            }
                        }
                    }
                }

                // App list
                Bevel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    raised: false
                    face: "#ffffff"

                    ListView {
                        id: list
                        anchors.fill: parent
                        anchors.margins: Theme.px(2)
                        clip: true
                        model: win.apps
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: Rectangle {
                            id: row
                            required property var modelData
                            required property int index
                            width: list.width
                            height: Theme.z.row
                            color: hov.containsMouse ? Theme.c.blue : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.px(8)
                                anchors.rightMargin: Theme.px(8)
                                spacing: Theme.px(8)

                                AppGlyph {
                                    size: Theme.z.icon
                                    name: row.modelData.icon ?? ""
                                    fallbackText: String(row.modelData.name ?? "?")
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(row.modelData.name ?? "")
                                    color: hov.containsMouse ? "#ffffff" : Theme.c.ink
                                    font.family: Theme.f.display
                                    font.pixelSize: Theme.f.small
                                    elide: Text.ElideRight
                                    renderType: Text.NativeRendering
                                }
                            }

                            MouseArea {
                                id: hov
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.launch(row.modelData)
                            }
                        }
                    }
                }

                // Power row
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.z.row
                    spacing: Theme.px(5)

                    BevelButton {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        text: "Lock"; fontFamily: Theme.f.display; fontSize: Theme.f.tiny
                        onClicked: win.run("loginctl lock-session")
                    }
                    BevelButton {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        text: "Log Off"; fontFamily: Theme.f.display; fontSize: Theme.f.tiny
                        onClicked: win.run("hyprctl dispatch exit")
                    }
                    BevelButton {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        text: "Restart"; fontFamily: Theme.f.display; fontSize: Theme.f.tiny
                        onClicked: win.run("systemctl reboot")
                    }
                    BevelButton {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        text: "Shut Down"; fontFamily: Theme.f.display; fontSize: Theme.f.tiny
                        face: Theme.c.pink; textColor: "#ffffff"
                        onClicked: win.run("systemctl poweroff")
                    }
                }
            }
        }
    }
}
