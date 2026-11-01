pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property color paper: "#e8ddcc"
    readonly property color paperLight: "#efe5d5"
    readonly property color paperDark: "#ddd0ba"
    readonly property color paperDeep: "#d3c6ae"
    readonly property color ink: "#222224"
    readonly property color inkSoft: "#3b3834"
    readonly property color inkFaint: "#8b8376"
    readonly property color line: "#c9bca6"
    readonly property color blue: "#6aa5e4"
    readonly property color blueSoft: "#bccde3"
    readonly property color blueInk: "#2f7fc8"
    readonly property color red: "#e35951"
    readonly property color yellow: "#f3b138"
    readonly property color green: "#6dbd3d"
    readonly property color coral: "#e27268"

    readonly property string ui: uiRegular.status === FontLoader.Ready ? uiRegular.name : "Gaegu"
    readonly property string script: scriptFace.status === FontLoader.Ready ? scriptFace.name : "Shadows Into Light Two"
    readonly property string mono: monoFace.status === FontLoader.Ready ? monoFace.name : "Paper Mono"

    function asset(path: string): url {
        return Qt.resolvedUrl("assets/" + path);
    }

    function icon(name: string): url {
        return root.asset("icons/" + name + ".png");
    }

    function unit(screen: var): real {
        const h = screen ? screen.height : 1080;
        return Math.max(0.8, h / 720) * Config.scale;
    }

    FontLoader { id: uiLight; source: root.asset("fonts/Gaegu-Light.ttf") }
    FontLoader { id: uiRegular; source: root.asset("fonts/Gaegu-Regular.ttf") }
    FontLoader { id: uiBold; source: root.asset("fonts/Gaegu-Bold.ttf") }
    FontLoader { id: scriptFace; source: root.asset("fonts/ShadowsIntoLightTwo-Regular.ttf") }
    FontLoader { id: monoFace; source: root.asset("fonts/PaperMono-Regular.ttf") }
}
