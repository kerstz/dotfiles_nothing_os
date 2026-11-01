import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../../components"
import "../../services"

Column {
    id: root

    property real u: 2
    property string info: ""
    property var rices: []
    property string current: "paper"

    spacing: 3 * u

    Process {
        running: true
        command: ["sh", "-c", ". /etc/os-release; echo \"$PRETTY_NAME\"; uname -r; uname -n; hyprctl version -j | jq -r .tag; qs --version | head -1"]
        stdout: StdioCollector { onStreamFinished: root.info = this.text.trim() }
    }

    Process {
        running: true
        command: ["sh", `${Sys.scripts}/rice.sh`, "list"]
        stdout: StdioCollector { onStreamFinished: root.rices = this.text.trim().split("\n").filter(s => s !== "") }
    }

    Process {
        running: true
        command: ["sh", `${Sys.scripts}/rice.sh`, "current"]
        stdout: StdioCollector { onStreamFinished: root.current = this.text.trim() }
    }

    SectionTitle { u: root.u; text: "This machine" }

    Repeater {
        model: {
            const labels = ["System", "Kernel", "Name", "Hyprland", "Shell"];
            return root.info.split("\n").map((v, i) => ({ label: labels[i] ?? "", value: v }));
        }

        SettingRow {
            id: fact

            required property var modelData

            u: root.u
            label: modelData.label

            Hand {
                text: fact.modelData.value
                font.pixelSize: 15.5 * root.u
                color: Theme.inkSoft
            }
        }
    }

    SectionTitle { u: root.u; text: "Rice" }

    Choice {
        u: root.u
        value: root.current
        options: root.rices.map(r => ({ label: r, value: r }))
        onPicked: v => {
            if (v !== root.current)
                Quickshell.execDetached(["sh", `${Sys.scripts}/rice.sh`, "set", v]);
        }
    }

    SectionTitle { u: root.u; text: "Shell" }

    SettingRow {
        u: root.u
        label: "Reload the shell"
        hint: "CTRL + SUPER + R"
        PaperButton { u: root.u; label: "Reload"; onClicked: Quickshell.reload(false) }
    }
}
