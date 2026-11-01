pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool wifiOn: true
    property bool online: false
    property string active: ""
    property var networks: []
    property string message: ""
    property bool busy: false
    property string pendingSsid: ""

    function refresh(): void {
        stateProbe.running = true;
        listProbe.running = true;
    }

    function scan(): void {
        Quickshell.execDetached(["nmcli", "device", "wifi", "rescan"]);
        rescanTimer.restart();
    }

    function setWifi(on: bool): void {
        root.wifiOn = on;
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
        rescanTimer.restart();
    }

    function connectTo(ssid: string, password: string): void {
        root.busy = true;
        root.message = "";
        root.pendingSsid = ssid;
        const argv = ["nmcli", "device", "wifi", "connect", ssid];
        if (password !== "")
            argv.push("password", password);
        connector.command = argv;
        connector.running = true;
    }

    function disconnectFrom(ssid: string): void {
        Quickshell.execDetached(["nmcli", "connection", "down", "id", ssid]);
        rescanTimer.restart();
    }

    function forget(ssid: string): void {
        Quickshell.execDetached(["nmcli", "connection", "delete", "id", ssid]);
        rescanTimer.restart();
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: stateProbe.running = true
    }

    Timer {
        id: rescanTimer
        interval: 2200
        onTriggered: root.refresh()
    }

    Process {
        id: stateProbe
        command: ["sh", "-c", "nmcli -t -f STATE g; nmcli -t -f WIFI g; nmcli -t -f NAME,TYPE connection show --active | grep -E 'wireless|ethernet' | head -1 | cut -d: -f1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n");
                root.online = (lines[0] ?? "").startsWith("connected");
                root.wifiOn = (lines[1] ?? "") === "enabled";
                root.active = lines[2] ?? "";
            }
        }
    }

    Process {
        id: listProbe
        command: ["nmcli", "-t", "-e", "yes", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "no"]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = {};
                const out = [];
                const lines = this.text.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(/(?<!\\):/).map(p => p.replace(/\\:/g, ":"));
                    if (parts.length < 4 || parts[1] === "" || seen[parts[1]])
                        continue;
                    seen[parts[1]] = true;
                    out.push({ inUse: parts[0] === "*", ssid: parts[1], signal: Number(parts[2]), secure: parts[3] !== "" });
                }
                out.sort((a, b) => (b.inUse - a.inUse) || (b.signal - a.signal));
                root.networks = out;
            }
        }
    }

    Process {
        id: connector
        stdout: StdioCollector { id: connectOut }
        stderr: StdioCollector { id: connectErr }
        onExited: code => {
            root.busy = false;
            root.message = code === 0 ? "" : (connectErr.text.trim() || connectOut.text.trim() || "Could not connect");
            root.refresh();
        }
    }
}
