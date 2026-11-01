import QtQuick
import "../.."
import "../../components"
import "../../services"

Column {
    id: root

    property real u: 2

    spacing: 3 * u

    SectionTitle { u: root.u; text: "Game" }

    SettingRow {
        u: root.u
        label: "Game mode"
        hint: "SUPER + G. Stops animations and holds notifications"
        Toggle { u: root.u; checked: Sys.game; onToggled: v => Sys.setGame(v) }
    }

    SectionTitle { u: root.u; text: "Crosshair" }

    SettingRow {
        u: root.u
        label: "Show crosshair"
        hint: "SUPER + ALT + X"
        Toggle { u: root.u; checked: Sys.crosshair; onToggled: v => Sys.crosshair = v }
    }

    SettingRow {
        u: root.u
        label: "Size"
        Slide { width: 150 * root.u; u: root.u; value: (Config.crosshairSize - 4) / 36; tone: Theme.blueInk; onMoved: v => Config.set("crosshairSize", 4 + v * 36) }
    }

    SettingRow {
        u: root.u
        label: "Colour"
        Choice {
            u: root.u
            value: Config.crosshairColor
            options: [
                { label: "Coral", value: "#e27268" }, { label: "Green", value: "#6dbd3d" },
                { label: "Cyan", value: "#35c8d8" }, { label: "White", value: "#ffffff" }
            ]
            onPicked: v => Config.set("crosshairColor", v)
        }
    }
}
