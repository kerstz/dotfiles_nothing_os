import QtQuick
import Quickshell
import "../.."
import "../../components"

Item {
    id: root

    property real u: 2

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    readonly property int hour24: clock.date.getHours()
    readonly property string hours: Config.clock24 ? String(hour24).padStart(2, "0") : String(hour24 % 12 === 0 ? 12 : hour24 % 12)
    readonly property string minutes: String(clock.date.getMinutes()).padStart(2, "0")
    readonly property string meridian: Config.clock24 ? "" : (hour24 < 12 ? "AM" : "PM")

    Card {
        anchors.fill: parent
        u: root.u
        name: "clock"
    }

    Hand {
        anchors.right: colon.left
        anchors.rightMargin: 3 * root.u
        y: 8 * root.u
        script: true
        text: root.hours
        font.pixelSize: 52 * root.u
        font.letterSpacing: 3 * root.u
    }

    Hand {
        id: colon
        x: 76 * root.u
        y: 13 * root.u
        script: true
        text: ":"
        font.pixelSize: 44 * root.u
    }

    Hand {
        x: 88 * root.u
        y: 8 * root.u
        script: true
        text: root.minutes
        font.pixelSize: 52 * root.u
        font.letterSpacing: 1.5 * root.u
    }

    Hand {
        x: 147 * root.u
        y: 44 * root.u
        text: root.meridian
        font.pixelSize: 17 * root.u
        color: Theme.inkSoft
    }

    Hand {
        x: 29 * root.u
        y: 71 * root.u
        text: clock.date.toLocaleString(Config.locale, "ddd, d MMM yyyy")
        font.pixelSize: 16 * root.u
        color: Theme.ink
    }

    Rectangle {
        x: 32 * root.u
        y: 96.4 * root.u
        width: 97 * root.u
        height: 1.5 * root.u
        radius: height / 2
        color: Theme.coral
        rotation: -0.35
        opacity: 0.92
    }

    Doodle {
        name: "leaf"
        x: 140 * root.u
        y: 66 * root.u
        width: 21 * root.u
        height: 42 * root.u
        rotation: 22
    }
}
