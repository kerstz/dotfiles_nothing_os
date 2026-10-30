pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property real scale: 1.0

    readonly property url wallpaper: Qt.resolvedUrl("assets/wallpaper.png")
    readonly property url scanlines: Qt.resolvedUrl("assets/scanlines.png")
    readonly property url vignette:  Qt.resolvedUrl("assets/vignette.png")

    // CRT flourish over the whole screen. On by default - it is the rice.
    property bool crt: true
    property bool crtFlicker: true

    // Pinned quick-launch ids for the start menu's top row.
    readonly property var pinned: [
        "firefox", "kitty", "cool-retro-term", "dolphin", "code", "spotify"
    ]
}
