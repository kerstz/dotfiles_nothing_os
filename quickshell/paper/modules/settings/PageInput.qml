import QtQuick
import "../.."
import "../../components"
import "../../services"

Column {
    id: root

    property real u: 2

    spacing: 3 * u

    function update(key: string, value: var): void {
        Config.set(key, value);
        Sys.applyHypr();
    }

    SectionTitle { u: root.u; text: "Keyboard" }

    SettingRow {
        u: root.u
        label: "Layout"
        hint: "Empty keeps the system one"
        Field { width: 110 * root.u; u: root.u; text: Config.kbLayout; placeholder: "fr, us..."; onCommitted: t => root.update("kbLayout", t.trim()) }
    }

    SettingRow {
        u: root.u
        label: "Variant"
        Field { width: 110 * root.u; u: root.u; text: Config.kbVariant; placeholder: "intl..."; onCommitted: t => root.update("kbVariant", t.trim()) }
    }

    SectionTitle { u: root.u; text: "Mouse" }

    SettingRow {
        u: root.u
        label: "Speed"
        hint: Config.sensitivity.toFixed(2)
        Slide { width: 150 * root.u; u: root.u; value: (Config.sensitivity + 1) / 2; tone: Theme.blueInk; onMoved: v => root.update("sensitivity", Math.round((v * 2 - 1) * 20) / 20) }
    }

    SettingRow {
        u: root.u
        label: "Natural scrolling"
        Toggle { u: root.u; checked: Config.naturalScroll; onToggled: v => root.update("naturalScroll", v) }
    }

    SectionTitle { u: root.u; text: "Touchpad" }

    SettingRow {
        u: root.u
        label: "Natural scrolling"
        Toggle { u: root.u; checked: Config.touchNatural; onToggled: v => root.update("touchNatural", v) }
    }

    SettingRow {
        u: root.u
        label: "Tap to click"
        Toggle { u: root.u; checked: Config.touchTap; onToggled: v => root.update("touchTap", v) }
    }
}
