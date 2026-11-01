import QtQuick
import Quickshell
import "../.."
import "../../components"

Column {
    id: root

    property real u: 2
    property string query: ""

    readonly property var pinned: {
        const v = Config.pinned;
        const out = [];
        if (v) {
            for (let i = 0; i < v.length; i++)
                out.push(String(v[i]));
        }
        return out;
    }

    readonly property var apps: {
        const list = DesktopEntries.applications?.values ?? [];
        const q = root.query.toLowerCase();
        return list.filter(e => !e.noDisplay && (q === "" || String(e.name).toLowerCase().indexOf(q) >= 0))
            .sort((a, b) => String(a.name).localeCompare(String(b.name))).slice(0, 40);
    }

    spacing: 3 * u

    function togglePin(id: string): void {
        const list = root.pinned.slice();
        const at = list.indexOf(id);
        if (at >= 0)
            list.splice(at, 1);
        else
            list.push(id);
        Config.set("pinned", list);
    }

    SectionTitle { u: root.u; text: "Bar" }

    SettingRow { u: root.u; label: "Show the bar"; hint: "SUPER + N"; Toggle { u: root.u; checked: Config.showBar; onToggled: v => Config.set("showBar", v) } }
    SettingRow { u: root.u; label: "System tray"; hint: "Icons of apps running in the background"; Toggle { u: root.u; checked: Config.showTray; onToggled: v => Config.set("showTray", v) } }
    SettingRow { u: root.u; label: "Battery"; hint: "Only on machines that have one"; Toggle { u: root.u; checked: Config.showBattery; onToggled: v => Config.set("showBattery", v) } }

    SectionTitle { u: root.u; text: "Dock" }

    SettingRow { u: root.u; label: "Show the dock"; Toggle { u: root.u; checked: Config.showDock; onToggled: v => Config.set("showDock", v) } }

    Hand { text: "Pin more apps"; font.pixelSize: 16 * root.u }

    Field {
        width: parent.width - 8 * root.u
        u: root.u
        placeholder: "Search apps..."
        onTextChanged: root.query = text
    }

    Repeater {
        model: root.apps

        SettingRow {
            id: appRow

            required property var modelData

            u: root.u
            label: modelData.name

            Toggle {
                u: root.u
                checked: root.pinned.indexOf(appRow.modelData.id) >= 0
                onToggled: root.togglePin(appRow.modelData.id)
            }
        }
    }
}
