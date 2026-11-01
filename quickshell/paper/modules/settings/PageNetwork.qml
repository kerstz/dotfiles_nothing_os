import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "../.."
import "../../components"
import "../../services"

Column {
    id: root

    property real u: 2
    property string askFor: ""

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: (Bluetooth.devices?.values ?? []).slice().sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || String(a.name).localeCompare(String(b.name)))

    spacing: 3 * u

    Component.onCompleted: Net.refresh()

    SectionTitle { u: root.u; text: "Wi-Fi" }

    SettingRow {
        u: root.u
        label: "Wi-Fi"
        hint: Net.active !== "" ? `Connected: ${Net.active}` : "Not connected"
        Row {
            spacing: 6 * root.u
            PaperButton { u: root.u; label: "Scan"; onClicked: Net.scan() }
            Toggle { u: root.u; checked: Net.wifiOn; onToggled: v => Net.setWifi(v) }
        }
    }

    Hand {
        visible: Net.message !== ""
        width: parent.width
        wrapMode: Text.WordWrap
        text: Net.message
        font.pixelSize: 14.5 * root.u
        color: Theme.red
    }

    Repeater {
        model: Net.networks

        Column {
            id: net

            required property var modelData

            width: root.width

            SettingRow {
                u: root.u
                label: `${net.modelData.inUse ? "* " : ""}${net.modelData.ssid}`
                hint: `${net.modelData.signal} %${net.modelData.secure ? "  locked" : ""}`
                Row {
                    spacing: 5 * root.u
                    PaperButton {
                        u: root.u
                        label: net.modelData.inUse ? "Disconnect" : "Connect"
                        onClicked: {
                            if (net.modelData.inUse)
                                Net.disconnectFrom(net.modelData.ssid);
                            else if (net.modelData.secure)
                                root.askFor = net.modelData.ssid;
                            else
                                Net.connectTo(net.modelData.ssid, "");
                        }
                    }
                    PaperButton { u: root.u; label: "Forget"; onClicked: Net.forget(net.modelData.ssid) }
                }
            }

            Item {
                visible: root.askFor === net.modelData.ssid
                width: parent.width
                height: visible ? 30 * root.u : 0

                TextInput {
                    id: pass
                    width: parent.width - 80 * root.u
                    height: 24 * root.u
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "*"
                    clip: true
                    color: Theme.ink
                    font.family: Theme.ui
                    font.pixelSize: 16 * root.u
                    onAccepted: {
                        Net.connectTo(net.modelData.ssid, text);
                        text = "";
                        root.askFor = "";
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -2 * root.u
                        z: -1
                        radius: 4 * root.u
                        color: Theme.paperLight
                        border.width: Math.max(1, 0.5 * root.u)
                        border.color: Theme.inkSoft
                    }
                }

                PaperButton {
                    anchors.right: parent.right
                    u: root.u
                    label: "Join"
                    onClicked: pass.accepted()
                }
            }
        }
    }

    SectionTitle { u: root.u; text: "Bluetooth" }

    SettingRow {
        u: root.u
        label: "Bluetooth"
        Row {
            spacing: 6 * root.u
            PaperButton {
                u: root.u
                label: (root.adapter?.discovering ?? false) ? "Stop looking" : "Look for devices"
                onClicked: {
                    if (root.adapter)
                        root.adapter.discovering = !root.adapter.discovering;
                }
            }
            Toggle {
                u: root.u
                checked: root.adapter?.enabled ?? false
                onToggled: v => {
                    if (root.adapter)
                        root.adapter.enabled = v;
                }
            }
        }
    }

    Repeater {
        model: root.devices

        SettingRow {
            id: device

            required property var modelData

            u: root.u
            label: modelData.name || modelData.address
            hint: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "Available")

            Row {
                spacing: 5 * root.u
                PaperButton {
                    u: root.u
                    label: device.modelData.connected ? "Disconnect" : (device.modelData.paired ? "Connect" : "Pair")
                    onClicked: {
                        if (device.modelData.connected)
                            device.modelData.disconnect();
                        else if (device.modelData.paired)
                            device.modelData.connect();
                        else
                            device.modelData.pair();
                    }
                }
                PaperButton {
                    visible: device.modelData.paired
                    u: root.u
                    label: "Forget"
                    onClicked: device.modelData.forget()
                }
            }
        }
    }
}
