pragma Singleton

import QtQuick
import Quickshell

// Nocturne: dark violet, cold, glacial. Deep near-black purples, muted
// violet surfaces, icy violet/magenta accents. All dimensions run through
// px() so the whole shell scales from one knob.
Singleton {
    id: root

    readonly property real s: Config.scale
    function px(v: real): int { return Math.round(v * root.s); }

    readonly property QtObject c: QtObject {
        readonly property color bg:       "#06040f"   // under the wallpaper
        readonly property color surface:  "#0e0a1e"   // taskbar / panel base
        readonly property color surface2: "#161130"   // cards
        readonly property color surface3: "#211a44"   // hover
        readonly property color surface4: "#2d2458"   // active / pressed
        readonly property color on:       "#e9e4ff"   // icy white-violet ink
        readonly property color onDim:    "#a79cd6"
        readonly property color onFaint:  "#5b5388"
        readonly property color outline:  "#352c63"
        readonly property color accent:   Config.accent          // icy violet
        readonly property color accent2:  "#c9b6ff"              // brighter rim
        readonly property color magenta:  "#e879f9"              // cold magenta
        readonly property color accentInk: "#0a0718"
        readonly property color scrim:    Qt.rgba(0.02, 0.01, 0.06, 0.55)
        readonly property color good:     "#7ee7d0"
        readonly property color warn:     "#f5b57a"
    }

    // Frosted glass: a translucent tint of a surface, for panels floating
    // over the wallpaper. Hyprland's blur sits behind the alpha.
    function frost(a: real): color {
        return Qt.rgba(root.c.surface.r, root.c.surface.g, root.c.surface.b, a);
    }
    function tint(col: color, a: real): color {
        return Qt.rgba(col.r, col.g, col.b, a);
    }

    readonly property QtObject f: QtObject {
        readonly property string display: "Orbitron"              // glacial display
        readonly property string sans:    "Inter"
        readonly property string mono:    "JetBrainsMono NF"
        readonly property string glyphs:  "JetBrainsMono Nerd Font Propo"

        readonly property int micro: root.px(9)
        readonly property int tiny:  root.px(10)
        readonly property int small: root.px(11)
        readonly property int body:  root.px(13)
        readonly property int big:   root.px(15)
        readonly property int huge:  root.px(22)
        readonly property real track: 1.2
    }

    readonly property QtObject r: QtObject {
        readonly property int pill:  999
        readonly property int panel: root.px(16)
        readonly property int card:  root.px(12)
        readonly property int chip:  root.px(9)
        readonly property int tiny:  root.px(6)
    }

    readonly property QtObject z: QtObject {
        readonly property int bar:      root.px(44)   // taskbar height
        readonly property int taskBtn:  root.px(36)
        readonly property int icon:     root.px(13)
        readonly property int iconM:    root.px(16)
        readonly property int iconL:    root.px(20)
        readonly property int start:    root.px(560)  // start-menu width
        readonly property int startTile: root.px(92)
    }

    readonly property int gap: root.px(8)
    readonly property int pad: root.px(14)

    // Cold and smooth, with a faint glacial glide.
    readonly property int fast: 130
    readonly property int med:  220
    readonly property int slow: 360
    readonly property var ease: Easing.OutExpo
}
