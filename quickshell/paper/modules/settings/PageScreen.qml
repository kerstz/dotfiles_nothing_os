import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../../components"
import "../../services"

Column {
    id: root

    property real u: 2
    property var monitors: []
    property var previous: []
    property int countdown: 0

    spacing: 3 * u

    function ruleOf(m: var): string {
        if (m.disabled)
            return `hl.monitor({ output = ${JSON.stringify(m.name)}, disabled = true })`;
        return `hl.monitor({ output = ${JSON.stringify(m.name)}, mode = ${JSON.stringify(m.mode)}, position = ${JSON.stringify(`${m.x}x${m.y}`)}, scale = ${m.scale}, transform = ${m.transform}, mirror = "none" })`;
    }

    function applyAll(list: var): void {
        for (let i = 0; i < list.length; i++)
            Quickshell.execDetached(["hyprctl", "eval", root.ruleOf(list[i])]);
    }

    function change(index: int, key: string, value: var): void {
        const list = root.monitors.map(m => Object.assign({}, m));
        if (root.countdown === 0)
            root.previous = root.monitors.map(m => Object.assign({}, m));
        list[index][key] = value;
        root.monitors = list;
        root.applyAll(list);
        root.countdown = 15;
        revert.restart();
    }

    function keep(): void {
        revert.stop();
        root.countdown = 0;
        const body = root.monitors.map(root.ruleOf).join("\n");
        keeper.setText(`${body}\n`);
    }

    function undo(): void {
        revert.stop();
        root.countdown = 0;
        root.monitors = root.previous;
        root.applyAll(root.previous);
    }

    Timer {
        id: revert
        interval: 1000
        repeat: true
        onTriggered: {
            root.countdown -= 1;
            if (root.countdown <= 0)
                root.undo();
        }
    }

    FileView {
        id: keeper
        path: `${Sys.home}/.config/hypr/displays.lua`
        atomicWrites: true
    }

    Process {
        running: true
        command: ["hyprctl", "-j", "monitors", "all"]
        stdout: StdioCollector {
            onStreamFinished: {
                const data = JSON.parse(this.text);
                root.monitors = data.map(m => ({
                    name: m.name,
                    description: m.description,
                    mode: `${m.width}x${m.height}@${Number(m.refreshRate).toFixed(2)}`,
                    modes: m.availableModes.map(s => s.replace("Hz", "")),
                    x: m.x,
                    y: m.y,
                    scale: m.scale,
                    transform: m.transform,
                    disabled: m.disabled
                }));
            }
        }
    }

    SectionTitle { u: root.u; text: "Screens" }

    Item {
        visible: root.countdown > 0
        width: parent.width
        height: 30 * root.u

        Hand {
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            text: `Keep this? Going back in ${root.countdown} s`
            font.pixelSize: 16 * root.u
            color: Theme.red
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5 * root.u
            PaperButton { u: root.u; label: "Keep"; tone: Theme.blueSoft; onClicked: root.keep() }
            PaperButton { u: root.u; label: "Undo"; onClicked: root.undo() }
        }
    }

    Repeater {
        model: root.monitors

        Column {
            id: mon

            required property var modelData
            required property int index

            width: root.width
            spacing: 2 * root.u

            Hand {
                width: parent.width
                elide: Text.ElideRight
                heavy: true
                text: `${mon.modelData.name}  ${mon.modelData.description}`
                font.pixelSize: 15.5 * root.u
            }

            SettingRow {
                u: root.u
                label: "Resolution"
                Row {
                    spacing: 4 * root.u
                    IconButton {
                        u: root.u
                        size: 10 * root.u
                        box: 21 * root.u
                        icon: "back"
                        onClicked: {
                            const at = mon.modelData.modes.indexOf(mon.modelData.mode);
                            root.change(mon.index, "mode", mon.modelData.modes[Math.min(mon.modelData.modes.length - 1, at + 1)]);
                        }
                    }
                    Hand {
                        width: 120 * root.u
                        height: 21 * root.u
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: mon.modelData.mode
                        font.pixelSize: 15 * root.u
                    }
                    IconButton {
                        u: root.u
                        size: 10 * root.u
                        box: 21 * root.u
                        icon: "forward"
                        onClicked: {
                            const at = mon.modelData.modes.indexOf(mon.modelData.mode);
                            root.change(mon.index, "mode", mon.modelData.modes[Math.max(0, at - 1)]);
                        }
                    }
                }
            }

            SettingRow {
                u: root.u
                label: "Scale"
                Choice {
                    u: root.u
                    value: mon.modelData.scale
                    options: [1, 1.25, 1.5, 2].map(s => ({ label: `${s}`, value: s }))
                    onPicked: v => root.change(mon.index, "scale", v)
                }
            }

            SettingRow {
                u: root.u
                label: "Rotation"
                Choice {
                    u: root.u
                    value: mon.modelData.transform
                    options: [{ label: "0", value: 0 }, { label: "90", value: 1 }, { label: "180", value: 2 }, { label: "270", value: 3 }]
                    onPicked: v => root.change(mon.index, "transform", v)
                }
            }
        }
    }

    SectionTitle { u: root.u; text: "Light" }

    SettingRow {
        u: root.u
        visible: Sys.backlightKind !== ""
        label: "Brightness"
        hint: Sys.backlightKind === "ddc" ? "Over DDC, can take a moment" : ""
        Slide { width: 150 * root.u; u: root.u; value: Sys.brightness; tone: Theme.yellow; onMoved: v => Sys.setBrightness(v) }
    }

    SettingRow {
        u: root.u
        label: "Night light"
        hint: "SUPER + ALT + B"
        Toggle { u: root.u; checked: Sys.night; onToggled: v => Sys.setNight(v) }
    }

    SettingRow {
        u: root.u
        label: "Warmth"
        hint: `${Config.nightKelvin} K`
        Slide {
            width: 150 * root.u
            u: root.u
            value: (6500 - Config.nightKelvin) / 4000
            tone: Theme.yellow
            onMoved: v => Sys.setKelvin(Math.round((6500 - v * 4000) / 100) * 100)
        }
    }

    SectionTitle { u: root.u; text: "When idle" }

    SettingRow {
        u: root.u
        label: "Keep awake"
        hint: "SUPER + ALT + I. Ignores everything below until turned off"
        Toggle { u: root.u; checked: Sys.caffeine; onToggled: v => Sys.setCaffeine(v) }
    }

    Repeater {
        model: [
            { label: "Dim", key: "idleDim" }, { label: "Lock", key: "idleLock" },
            { label: "Screen off", key: "idleOff" }, { label: "Suspend", key: "idleSuspend" }
        ]

        SettingRow {
            id: idleRow

            required property var modelData

            u: root.u
            label: modelData.label

            Choice {
                u: root.u
                value: Config[idleRow.modelData.key]
                options: [
                    { label: "Never", value: 0 }, { label: "2 min", value: 120 }, { label: "5 min", value: 300 },
                    { label: "10 min", value: 600 }, { label: "30 min", value: 1800 }
                ]
                onPicked: v => {
                    Config.set(idleRow.modelData.key, v);
                    Sys.writeIdle();
                }
            }
        }
    }
}
