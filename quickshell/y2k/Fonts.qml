pragma Singleton

import QtQuick
import Quickshell

// Bundled OFL pixel/retro faces, registered once for the whole shell.
Singleton {
    id: root

    readonly property string pixel:  psLoader.status === FontLoader.Ready ? psLoader.name : "Pixelify Sans"
    readonly property string arcade: paLoader.status === FontLoader.Ready ? paLoader.name : "Press Start 2P"
    readonly property string crt:    vtLoader.status === FontLoader.Ready ? vtLoader.name : "VT323"
    readonly property string mono:   stLoader.status === FontLoader.Ready ? stLoader.name : "Share Tech Mono"

    FontLoader { id: psLoader; source: Qt.resolvedUrl("assets/fonts/PixelifySans-Regular.ttf") }
    FontLoader { id: paLoader; source: Qt.resolvedUrl("assets/fonts/PressStart2P-Regular.ttf") }
    FontLoader { id: vtLoader; source: Qt.resolvedUrl("assets/fonts/VT323-Regular.ttf") }
    FontLoader { id: stLoader; source: Qt.resolvedUrl("assets/fonts/ShareTechMono-Regular.ttf") }
}
