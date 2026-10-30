pragma Singleton

import QtQuick
import Quickshell

// Y2K / turn-of-millennium desktop. Loud saturated colour, silver 3D
// chrome, beveled everything. All dimensions pass through px(Config.scale).
Singleton {
    id: root

    readonly property real s: Config.scale
    function px(v: real): int { return Math.round(v * root.s); }

    // ── Palette ───────────────────────────────────────────────────────
    readonly property QtObject c: QtObject {
        // The iconic teal desktop, pushed brighter.
        readonly property color desk:    "#00a2a2"
        readonly property color deskDeep: "#005a7a"

        // Silver / beige 3D chrome.
        readonly property color face:    "#c3c7cb"
        readonly property color faceLit: "#d7dadd"
        readonly property color beige:   "#d4d0c8"

        // Bevel edges, brightest to darkest.
        readonly property color hi:      "#ffffff"
        readonly property color light:   "#e6e8ea"
        readonly property color shadow:  "#808890"
        readonly property color dark:    "#3b3b45"

        readonly property color ink:     "#10101a"
        readonly property color inkDim:  "#4a4a58"

        // Loud accents.
        readonly property color pink:    "#ff2d9b"
        readonly property color blue:    "#2d6cff"
        readonly property color cyan:    "#19e0e0"
        readonly property color lime:    "#7cff3f"
        readonly property color violet:  "#b65cff"
        readonly property color yellow:  "#ffd21e"
        readonly property color orange:  "#ff7a1e"

        // Title bars: active runs a magenta -> electric-blue chrome gradient.
        readonly property color titleA:  "#ff2d9b"
        readonly property color titleB:  "#2d6cff"
        readonly property color titleInA: "#9aa0ab"
        readonly property color titleInB: "#6a7078"
        readonly property color onTitle: "#ffffff"

        // Phosphor, for CRT-styled wells and the clock.
        readonly property color phosphor: "#39ff8a"
        readonly property color well:     "#0b1a12"

        readonly property color scrim:   Qt.rgba(0.02, 0.05, 0.08, 0.55)
    }

    // ── Typography ────────────────────────────────────────────────────
    // display : Pixelify Sans  (chunky pixel UI)
    // arcade  : Press Start 2P  (tiny loud accents, Start button)
    // crt     : VT323          (phosphor terminal / clock)
    // mono    : Share Tech Mono (aligned digits)
    readonly property QtObject f: QtObject {
        readonly property string display: Fonts.pixel
        readonly property string arcade:  Fonts.arcade
        readonly property string crt:     Fonts.crt
        readonly property string mono:    Fonts.mono

        readonly property int micro: root.px(10)
        readonly property int tiny:  root.px(12)
        readonly property int small: root.px(14)
        readonly property int body:  root.px(16)
        readonly property int big:   root.px(20)
        readonly property int huge:  root.px(30)
    }

    // ── Bevel depths ──────────────────────────────────────────────────
    readonly property int edge: Math.max(2, root.px(2))

    // ── Dimensions ────────────────────────────────────────────────────
    readonly property QtObject z: QtObject {
        readonly property int taskbar:  root.px(40)
        readonly property int start:    root.px(90)   // start button width
        readonly property int tray:     root.px(22)
        readonly property int task:     root.px(176)  // max task-button width
        readonly property int icon:     root.px(18)
        readonly property int menuW:    root.px(300)
        readonly property int bannerW:  root.px(46)
        readonly property int row:      root.px(34)
    }

    readonly property int gap: root.px(5)
    readonly property int pad: root.px(8)

    // Chunky, snappy, no float.
    readonly property int fast: 90
    readonly property int med: 150
    readonly property var ease: Easing.OutQuad
}
