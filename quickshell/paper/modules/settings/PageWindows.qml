import QtQuick
import "../.."
import "../../components"
import "../../services"

Column {
    id: root

    property real u: 2

    spacing: 3 * u

    SectionTitle { u: root.u; text: "Layout" }

    SettingRow {
        u: root.u
        label: "How windows are arranged"
        hint: "Scattered sheets is the arrangement in the picture"
    }

    Choice {
        u: root.u
        value: Config.layoutName
        options: [
            { label: "Scattered sheets", value: "lua:paper" },
            { label: "Tiling", value: "dwindle" },
            { label: "Scrolling", value: "scrolling" },
            { label: "Essential", value: "lua:essential" }
        ]
        onPicked: v => {
            Config.set("layoutName", v);
            Sys.applyHypr();
        }
    }

    SectionTitle { u: root.u; text: "Motion" }

    SettingRow {
        u: root.u
        label: "Animations"
        Toggle {
            u: root.u
            checked: Config.animations
            onToggled: v => {
                Config.set("animations", v);
                Sys.applyHypr();
            }
        }
    }
}
