import QtQuick
import Quickshell
import Quickshell.Hyprland
import ".."
import "../components"

Scope {
    LazyLoader {
        active: GlobalState.settingsOpen

        FloatingWindow {
            id: win

            readonly property real u: Math.max(0.8, (Hyprland.focusedMonitor?.height ?? 1080) / 720) * Config.scale
            property string search: ""

            title: "Paper Settings"
            color: "transparent"
            implicitWidth: Math.round(640 * u)
            implicitHeight: Math.round(480 * u)
            onClosed: GlobalState.settingsOpen = false

            readonly property var pages: [
                { id: "look", label: "Appearance", icon: "image", file: "PageLook.qml", words: "wallpaper scale size clock quote photo widgets doodles language date theme" },
                { id: "bar", label: "Bar & dock", icon: "terminal_small", file: "PageBar.qml", words: "bar dock tray battery pinned apps hide show" },
                { id: "windows", label: "Windows", icon: "folder", file: "PageWindows.qml", words: "layout tiling dwindle scrolling essential animation gaps" },
                { id: "screen", label: "Screens", icon: "desktop", file: "PageScreen.qml", words: "display monitor resolution refresh scale rotation brightness night light idle lock suspend" },
                { id: "input", label: "Input", icon: "document", file: "PageInput.qml", words: "keyboard layout mouse sensitivity touchpad natural scroll tap" },
                { id: "sound", label: "Sound", icon: "volume", file: "PageSound.qml", words: "audio output input microphone volume speakers apps" },
                { id: "network", label: "Network", icon: "wifi", file: "PageNetwork.qml", words: "wifi wi-fi bluetooth pair connect network internet" },
                { id: "processes", label: "Processes", icon: "gear", file: "PageProcesses.qml", words: "process task manager kill cpu memory" },
                { id: "game", label: "Game", icon: "video", file: "PageGame.qml", words: "game mode crosshair notifications animations" },
                { id: "shortcuts", label: "Shortcuts", icon: "dots", file: "PageShortcuts.qml", words: "keys keyboard shortcuts binds cheat sheet" },
                { id: "about", label: "About", icon: "home", file: "PageAbout.qml", words: "about system version rice switch reload" }
            ]

            readonly property var shownPages: {
                const q = win.search.toLowerCase();
                if (q === "")
                    return win.pages;
                return win.pages.filter(p => p.label.toLowerCase().indexOf(q) >= 0 || p.words.indexOf(q) >= 0);
            }

            readonly property var currentPage: win.pages.find(p => p.id === GlobalState.settingsPage) ?? win.pages[0]

            Item {
                id: page
                anchors.fill: parent
                anchors.margins: 8 * win.u

                Sheet {
                    anchors.fill: parent
                    u: win.u
                    variant: 2
                }

                Rectangle {
                    x: 2 * win.u
                    y: 2 * win.u
                    width: 150 * win.u
                    height: 40 * win.u
                    radius: 3 * win.u
                    color: Theme.paperDeep
                    opacity: 0.8
                }

                Rectangle {
                    x: 2 * win.u
                    y: 42 * win.u
                    width: parent.width - 4 * win.u
                    height: Math.max(1, 0.5 * win.u)
                    color: Theme.line
                }

                Rectangle {
                    x: 152 * win.u
                    y: 2 * win.u
                    width: Math.max(1, 0.5 * win.u)
                    height: parent.height - 5 * win.u
                    color: Theme.line
                }

                Lights {
                    x: 16 * win.u
                    y: 16 * win.u
                    u: win.u
                    onCloseClicked: GlobalState.settingsOpen = false
                    onMinClicked: GlobalState.settingsOpen = false
                    onMaxClicked: Hyprland.dispatch(`hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })`)
                }

                Hand {
                    x: 168 * win.u
                    y: 2 * win.u
                    height: 40 * win.u
                    verticalAlignment: Text.AlignVCenter
                    heavy: true
                    text: win.currentPage.label
                    font.pixelSize: 19 * win.u
                }

                Ico {
                    x: 12 * win.u
                    y: 54 * win.u
                    size: 12 * win.u
                    name: "search"
                }

                TextInput {
                    id: searchInput
                    x: 30 * win.u
                    y: 48 * win.u
                    width: 115 * win.u
                    height: 24 * win.u
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    color: Theme.ink
                    selectionColor: Theme.blueSoft
                    font.family: Theme.ui
                    font.pixelSize: 15.5 * win.u
                    onTextChanged: win.search = text

                    Hand {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        visible: searchInput.text === ""
                        text: "Search..."
                        font.pixelSize: 15.5 * win.u
                        color: Theme.inkFaint
                    }
                }

                Column {
                    x: 7 * win.u
                    y: 76 * win.u
                    width: 138 * win.u

                    Repeater {
                        model: win.shownPages

                        Item {
                            id: nav

                            required property var modelData
                            readonly property bool current: GlobalState.settingsPage === modelData.id

                            width: parent.width
                            height: 30 * win.u

                            Rectangle {
                                anchors.fill: parent
                                anchors.topMargin: 1.4 * win.u
                                anchors.bottomMargin: 1.4 * win.u
                                radius: 5 * win.u
                                color: Theme.blueSoft
                                opacity: nav.current ? 0.95 : (navMouse.containsMouse ? 0.4 : 0)
                            }

                            Ico {
                                x: 8 * win.u
                                anchors.verticalCenter: parent.verticalCenter
                                size: 15 * win.u
                                name: nav.modelData.icon
                            }

                            Hand {
                                x: 30 * win.u
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                text: nav.modelData.label
                                font.pixelSize: 15.8 * win.u
                                color: nav.current ? Theme.ink : Theme.inkSoft
                            }

                            MouseArea {
                                id: navMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: GlobalState.settingsPage = nav.modelData.id
                            }
                        }
                    }
                }

                Flickable {
                    id: flick
                    x: 164 * win.u
                    y: 48 * win.u
                    width: parent.width - 176 * win.u
                    height: parent.height - 56 * win.u
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    contentWidth: width
                    contentHeight: loader.item ? loader.item.implicitHeight : 0

                    Loader {
                        id: loader
                        width: flick.width
                        source: `settings/${win.currentPage.file}`
                        onLoaded: {
                            item.u = Qt.binding(() => win.u);
                            item.width = Qt.binding(() => flick.width);
                            flick.contentY = 0;
                        }
                    }
                }

                Rectangle {
                    visible: flick.contentHeight > flick.height
                    x: parent.width - 5 * win.u
                    y: flick.y + flick.visibleArea.yPosition * flick.height
                    width: 2.2 * win.u
                    height: flick.visibleArea.heightRatio * flick.height
                    radius: width / 2
                    color: Theme.inkFaint
                    opacity: 0.55
                }
            }
        }
    }
}
