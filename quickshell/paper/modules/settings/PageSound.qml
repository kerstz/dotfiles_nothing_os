import QtQuick
import Quickshell.Services.Pipewire
import "../.."
import "../../components"

Column {
    id: root

    property real u: 2

    readonly property var nodes: Pipewire.nodes?.values ?? []
    readonly property var outputs: nodes.filter(n => n.isSink && !n.isStream && n.audio)
    readonly property var inputs: nodes.filter(n => !n.isSink && !n.isStream && n.audio)
    readonly property var streams: nodes.filter(n => n.isStream && n.audio && n.isSink)

    spacing: 3 * u

    PwObjectTracker { objects: root.outputs.concat(root.inputs).concat(root.streams) }

    SectionTitle { u: root.u; text: "Output" }

    Repeater {
        model: root.outputs

        Item {
            id: out

            required property var modelData
            readonly property bool current: Pipewire.defaultAudioSink === modelData

            width: root.width
            height: 44 * root.u

            Rectangle {
                anchors.fill: parent
                anchors.bottomMargin: 2 * root.u
                radius: 5 * root.u
                color: Theme.blueSoft
                opacity: out.current ? 0.7 : 0
            }

            Hand {
                x: 6 * root.u
                y: 3 * root.u
                width: parent.width - 12 * root.u
                elide: Text.ElideRight
                text: out.modelData.description || out.modelData.nickname || out.modelData.name
                font.pixelSize: 15.5 * root.u
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Pipewire.preferredDefaultAudioSink = out.modelData
            }

            Slide {
                x: 6 * root.u
                y: 21 * root.u
                width: parent.width - 12 * root.u
                u: root.u
                value: out.modelData.audio.volume
                onMoved: v => out.modelData.audio.volume = v
            }
        }
    }

    SectionTitle { u: root.u; text: "Input" }

    Repeater {
        model: root.inputs

        Item {
            id: inp

            required property var modelData
            readonly property bool current: Pipewire.defaultAudioSource === modelData

            width: root.width
            height: 44 * root.u

            Rectangle {
                anchors.fill: parent
                anchors.bottomMargin: 2 * root.u
                radius: 5 * root.u
                color: Theme.blueSoft
                opacity: inp.current ? 0.7 : 0
            }

            Hand {
                x: 6 * root.u
                y: 3 * root.u
                width: parent.width - 12 * root.u
                elide: Text.ElideRight
                text: inp.modelData.description || inp.modelData.nickname || inp.modelData.name
                font.pixelSize: 15.5 * root.u
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Pipewire.preferredDefaultAudioSource = inp.modelData
            }

            Slide {
                x: 6 * root.u
                y: 21 * root.u
                width: parent.width - 12 * root.u
                u: root.u
                value: inp.modelData.audio.volume
                tone: Theme.blueInk
                onMoved: v => inp.modelData.audio.volume = v
            }
        }
    }

    SectionTitle { u: root.u; text: "Apps" }

    Hand {
        visible: root.streams.length === 0
        script: true
        text: "Nothing is playing..."
        font.pixelSize: 17 * root.u
        color: Theme.inkFaint
    }

    Repeater {
        model: root.streams

        SettingRow {
            id: stream

            required property var modelData

            u: root.u
            label: modelData.properties["application.name"] ?? modelData.name

            Slide {
                width: 170 * root.u
                u: root.u
                value: stream.modelData.audio.volume
                onMoved: v => stream.modelData.audio.volume = v
            }
        }
    }
}
