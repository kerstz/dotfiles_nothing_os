pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import ".."

Singleton {
    id: root

    readonly property string repo: Quickshell.shellPath("../..")
    readonly property string scripts: `${repo}/scripts`
    readonly property string home: Quickshell.env("HOME")
    readonly property string idleConf: `${home}/.config/nothing/hypridle.conf`

    property bool caffeine: false
    property bool night: false
    property bool game: false
    property bool crosshair: false
    property bool recording: false
    property string backlightKind: ""
    property real brightness: 1
    property string osdKind: ""
    property real osdValue: 0
    property int osdTick: 0

    function run(argv: var): void {
        Quickshell.execDetached(argv);
    }

    function shell(text: string): void {
        Quickshell.execDetached(["sh", "-c", text]);
    }

    function notify(title: string, body: string): void {
        Quickshell.execDetached(["notify-send", "-a", "Paper", title, body]);
    }

    function flash(kind: string, value: real): void {
        root.osdKind = kind;
        root.osdValue = value;
        root.osdTick++;
    }

    function setNight(on: bool): void {
        root.night = on;
        if (on) {
            Quickshell.execDetached(["sh", "-c", "pidof hyprsunset >/dev/null || (setsid -f hyprsunset >/dev/null 2>&1; sleep 0.4); hyprctl hyprsunset temperature \"$1\"", "sh", String(Config.nightKelvin)]);
        } else {
            Quickshell.execDetached(["sh", "-c", "pidof hyprsunset >/dev/null && hyprctl hyprsunset identity"]);
        }
    }

    function setKelvin(k: int): void {
        Config.set("nightKelvin", k);
        if (root.night)
            Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(k)]);
    }

    function setCaffeine(on: bool): void {
        root.caffeine = on;
        if (on) {
            Quickshell.execDetached(["sh", "-c", "pkill -x hypridle"]);
        } else {
            root.restartIdle();
        }
    }

    function restartIdle(): void {
        Quickshell.execDetached(["sh", "-c",
            "pkill -x hypridle; i=0; while pgrep -x hypridle >/dev/null && [ $i -lt 30 ]; do sleep 0.1; i=$((i+1)); done; conf=\"$1\"; [ -s \"$conf\" ] || conf=\"$2\"; setsid -f hypridle -c \"$conf\" >/dev/null 2>&1",
            "sh", root.idleConf, `${root.repo}/hypr/hypridle.conf`]);
    }

    function writeIdle(): void {
        const listener = (timeout, on, off) => {
            if (timeout <= 0)
                return "";
            let out = `listener {\n    timeout = ${timeout}\n    on-timeout = ${on}\n`;
            if (off !== "")
                out += `    on-resume = ${off}\n`;
            return out + "}\n\n";
        };
        let s = `general {\n    lock_cmd = ${root.scripts}/lock.sh\n    before_sleep_cmd = loginctl lock-session\n    inhibit_sleep = 3\n}\n\n`;
        s += listener(Config.idleDim, "brightnessctl -s set 10%", "brightnessctl -r");
        s += listener(Config.idleLock, "loginctl lock-session", "");
        s += listener(Config.idleOff, "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'", "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'");
        s += listener(Config.idleSuspend, "systemctl suspend || loginctl suspend", "");
        Quickshell.execDetached(["mkdir", "-p", `${root.home}/.config/nothing`]);
        idleFile.setText(s);
        if (!root.caffeine)
            idleRestart.restart();
    }

    function hyprOverrides(): string {
        const input = [`sensitivity = ${Config.sensitivity}`, `natural_scroll = ${Config.naturalScroll}`,
            `touchpad = { natural_scroll = ${Config.touchNatural}, tap_to_click = ${Config.touchTap} }`];
        if (Config.kbLayout !== "")
            input.push(`kb_layout = ${JSON.stringify(Config.kbLayout)}`);
        if (Config.kbVariant !== "")
            input.push(`kb_variant = ${JSON.stringify(Config.kbVariant)}`);
        return `hl.config({\n    general = { layout = ${JSON.stringify(Config.layoutName)} },\n    animations = { enabled = ${Config.animations && !root.game} },\n    input = { ${input.join(", ")} },\n})\n`;
    }

    function applyHypr(): void {
        const text = root.hyprOverrides();
        hyprFile.setText(text);
        Quickshell.execDetached(["hyprctl", "eval", text]);
    }

    function setGame(on: bool): void {
        root.game = on;
        Quickshell.execDetached(["hyprctl", "eval", `hl.config({ animations = { enabled = ${Config.animations && !on} } })`]);
    }

    function screenshot(mode: string, action: string): void {
        Quickshell.execDetached(["sh", `${root.scripts}/screenshot.sh`, mode, action]);
    }

    function record(mode: string, audio: string): void {
        if (root.recording) {
            Quickshell.execDetached(["sh", `${root.scripts}/record.sh`, "stop"]);
            return;
        }
        if (mode === "region") {
            Quickshell.execDetached(["sh", "-c", "geo=$(slurp) || exit 0; exec sh \"$1\" start region \"$2\" \"$geo\"", "sh", `${root.scripts}/record.sh`, audio]);
        } else {
            Quickshell.execDetached(["sh", `${root.scripts}/record.sh`, "start", "screen", audio]);
        }
    }

    function lens(): void {
        Quickshell.execDetached(["sh", `${root.scripts}/lens.sh`]);
    }

    function song(): void {
        root.notify("Listening...", "Trying to recognise what is playing");
        songProbe.running = true;
    }

    function pickColour(): void {
        Quickshell.execDetached(["hyprpicker", "-a"]);
    }

    function setBrightness(v: real): void {
        const clamped = Math.max(0.01, Math.min(1, v));
        root.brightness = clamped;
        root.flash("brightness", clamped);
        brightnessApply.restart();
    }

    function nudgeBrightness(delta: real): void {
        root.setBrightness(root.brightness + delta);
    }

    Process {
        id: songProbe
        command: ["sh", `${root.scripts}/songrec.sh`, "8"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split("|");
                if (parts.length >= 2)
                    root.notify(parts[0], parts[1]);
                else
                    root.notify("No match", this.text.trim());
            }
        }
    }

    FileView {
        id: idleFile
        path: root.idleConf
        atomicWrites: true
    }

    Timer {
        id: idleRestart
        interval: 250
        onTriggered: root.restartIdle()
    }

    FileView {
        id: hyprFile
        path: `${Config.dir}/hypr.lua`
        atomicWrites: true
    }

    Timer {
        interval: 2500
        running: true
        repeat: true
        onTriggered: recordProbe.running = true
    }

    Process {
        id: recordProbe
        command: ["pgrep", "-x", "wf-recorder"]
        onExited: code => root.recording = code === 0
    }

    Process {
        id: backlightProbe
        running: true
        command: ["sh", "-c", "if ls /sys/class/backlight/* >/dev/null 2>&1; then echo backlight; brightnessctl -m --class backlight | cut -d, -f4; elif command -v ddcutil >/dev/null; then echo ddc; ddcutil getvcp 10 --brief 2>/dev/null | awk '{print $4\"%\"}' | head -1; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n");
                root.backlightKind = lines[0] ?? "";
                const pct = parseInt(lines[1] ?? "100");
                if (!isNaN(pct))
                    root.brightness = pct / 100;
            }
        }
    }

    Timer {
        id: brightnessApply
        interval: root.backlightKind === "ddc" ? 280 : 40
        onTriggered: {
            const pct = Math.round(root.brightness * 100);
            if (root.backlightKind === "backlight")
                Quickshell.execDetached(["brightnessctl", "-q", "--class", "backlight", "set", `${pct}%`]);
            else if (root.backlightKind === "ddc")
                Quickshell.execDetached(["sh", "-c", "for d in $(ddcutil detect --brief 2>/dev/null | sed -n 's/^Display \\([0-9]*\\).*/\\1/p'); do ddcutil --noverify --display \"$d\" setvcp 10 \"$1\" & done; wait", "sh", String(pct)]);
        }
    }
}
