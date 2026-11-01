import QtQuick
import "../.."
import "../../components"
import "../../services"

Column {
    id: root

    property real u: 2

    spacing: 3 * u

    SectionTitle { u: root.u; text: "Desk" }

    SettingRow {
        u: root.u
        label: "Interface size"
        hint: `${Math.round(Config.scale * 100)} % of the size in the picture`
        Slide {
            width: 150 * root.u
            u: root.u
            value: (Config.scale - 0.5) / 1.0
            tone: Theme.blueInk
            onMoved: v => Config.set("scale", Math.round((0.5 + v) * 20) / 20)
        }
    }

    SettingRow {
        u: root.u
        label: "Wallpaper"
        hint: Config.wallpaper !== "" ? Config.wallpaper : "Paper dusk, the one in the picture"
        Row {
            spacing: 5 * root.u
            PaperButton { u: root.u; label: "Choose..."; onClicked: GlobalState.wallpaperOpen = true }
            PaperButton { u: root.u; label: "Default"; onClicked: Config.set("wallpaper", "") }
        }
    }

    SettingRow {
        u: root.u
        label: "Wallpaper folder"
        hint: "Where the picker and SUPER + ALT + W look"
        Field {
            width: 190 * root.u
            u: root.u
            text: Config.wallpaperFolder
            placeholder: "~/Images/Wallpapers"
            onCommitted: t => Config.set("wallpaperFolder", t.replace(/^~/, Sys.home))
        }
    }

    SettingRow {
        u: root.u
        label: "Doodles"
        hint: "The cat, the handwritten note and the tape on the terminal"
        Toggle { u: root.u; checked: Config.showDoodles; onToggled: v => Config.set("showDoodles", v) }
    }

    SectionTitle { u: root.u; text: "Widgets" }

    SettingRow { u: root.u; label: "Clock"; Toggle { u: root.u; checked: Config.showClock; onToggled: v => Config.set("showClock", v) } }
    SettingRow { u: root.u; label: "Quote"; Toggle { u: root.u; checked: Config.showQuote; onToggled: v => Config.set("showQuote", v) } }
    SettingRow { u: root.u; label: "Todo"; Toggle { u: root.u; checked: Config.showTodo; onToggled: v => Config.set("showTodo", v) } }
    SettingRow { u: root.u; label: "Music"; Toggle { u: root.u; checked: Config.showMusic; onToggled: v => Config.set("showMusic", v) } }
    SettingRow { u: root.u; label: "Photo"; Toggle { u: root.u; checked: Config.showPhoto; onToggled: v => Config.set("showPhoto", v) } }

    SectionTitle { u: root.u; text: "Words" }

    SettingRow {
        u: root.u
        label: "24-hour clock"
        Toggle { u: root.u; checked: Config.clock24; onToggled: v => Config.set("clock24", v) }
    }

    SettingRow {
        u: root.u
        label: "Date language"
        Choice {
            u: root.u
            value: Config.localeName
            options: [{ label: "English", value: "en_GB" }, { label: "Français", value: "fr_FR" }]
            onPicked: v => Config.set("localeName", v)
        }
    }

    Hand { text: "Quote"; font.pixelSize: 16 * root.u }

    Field {
        width: parent.width - 8 * root.u
        u: root.u
        multiline: true
        text: Config.quote
        onCommitted: t => Config.set("quote", t)
    }

    Hand { text: "Photo caption"; font.pixelSize: 16 * root.u }

    Field {
        width: parent.width - 8 * root.u
        u: root.u
        multiline: true
        text: Config.photoCaption
        onCommitted: t => Config.set("photoCaption", t)
    }

    SettingRow {
        u: root.u
        label: "Photo file"
        Field {
            width: 190 * root.u
            u: root.u
            text: Config.photo
            placeholder: "Path to a picture"
            onCommitted: t => Config.set("photo", t)
        }
    }
}
