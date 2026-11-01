import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../../components"

Column {
    id: root

    property real u: 2
    property var rows: []
    property string query: ""

    readonly property var shown: {
        const q = root.query.toLowerCase();
        return q === "" ? root.rows : root.rows.filter(r => r.name.toLowerCase().indexOf(q) >= 0);
    }

    spacing: 3 * u

    Timer {
        interval: 2500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }

    Process {
        id: probe
        command: ["sh", "-c", "ps -eo pid=,pcpu=,rss=,comm= --sort=-pcpu | head -60"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                const lines = this.text.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    const m = lines[i].trim().match(/^(\d+)\s+([\d.]+)\s+(\d+)\s+(.*)$/);
                    if (m)
                        out.push({ pid: m[1], cpu: Number(m[2]), mem: Number(m[3]) / 1024, name: m[4] });
                }
                root.rows = out;
            }
        }
    }

    Field {
        width: parent.width - 8 * root.u
        u: root.u
        placeholder: "Filter..."
        onTextChanged: root.query = text
    }

    Repeater {
        model: root.shown

        Item {
            id: row

            required property var modelData

            width: root.width
            height: 24 * root.u

            Hand {
                width: parent.width * 0.42
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: row.modelData.name
                font.pixelSize: 15.5 * root.u
            }

            Hand {
                x: parent.width * 0.44
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                text: `${row.modelData.cpu.toFixed(1)} %`
                font.pixelSize: 14.5 * root.u
                color: Theme.inkSoft
            }

            Hand {
                x: parent.width * 0.6
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                text: `${Math.round(row.modelData.mem)} MB`
                font.pixelSize: 14.5 * root.u
                color: Theme.inkSoft
            }

            PaperButton {
                anchors.right: parent.right
                anchors.rightMargin: 6 * root.u
                anchors.verticalCenter: parent.verticalCenter
                u: root.u
                label: "End"
                onClicked: Quickshell.execDetached(["kill", row.modelData.pid])
            }
        }
    }
}
