import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"
import "widgets"

PanelWindow {
    id: win

    required property var modelData
    readonly property real u: Theme.unit(modelData)
    readonly property real originX: 880

    screen: modelData
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "paper-widgets"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; right: true }
    implicitWidth: Math.round(200 * u)

    function rx(v: real): real {
        return (v - originX) * u;
    }

    function ry(v: real): real {
        return v * u;
    }

    ClockCard {
        visible: Config.showClock
        x: win.rx(897)
        y: win.ry(52)
        width: 173 * win.u
        height: 108 * win.u
        u: win.u
    }

    QuoteCard {
        visible: Config.showQuote
        x: win.rx(902)
        y: win.ry(168)
        width: 168 * win.u
        height: 114 * win.u
        u: win.u
    }

    Tape {
        visible: Config.showClock && Config.showQuote
        tone: "blue"
        x: win.rx(908)
        y: win.ry(159)
        width: 154 * win.u
        height: 15 * win.u
        rotation: 0.9
    }

    TodoCard {
        visible: Config.showTodo
        x: win.rx(903)
        y: win.ry(290)
        width: 167 * win.u
        height: 145 * win.u
        u: win.u
    }

    MusicCard {
        visible: Config.showMusic
        x: win.rx(900)
        y: win.ry(447)
        width: 172 * win.u
        height: 136 * win.u
        u: win.u
    }

    PhotoCard {
        visible: Config.showPhoto
        x: win.rx(898)
        y: win.ry(595)
        width: 174 * win.u
        height: 95 * win.u
        u: win.u
    }
}
