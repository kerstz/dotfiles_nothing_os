import QtQuick
import Quickshell.Services.Mpris
import "../.."
import "../../components"

Item {
    id: root

    property real u: 2
    property bool liked: true

    readonly property var player: {
        const list = Mpris.players?.values ?? [];
        for (let i = 0; i < list.length; i++) {
            if (list[i].isPlaying)
                return list[i];
        }
        return list.length ? list[0] : null;
    }
    readonly property bool idle: player === null
    readonly property real position: idle ? 84 : (player.position ?? 0)
    readonly property real duration: idle ? 272 : (player.length ?? 0)
    readonly property real fraction: duration > 0 ? Math.min(1, position / duration) : 0
    readonly property string art: idle ? "" : String(player.trackArtUrl ?? "")

    function clock(seconds: real): string {
        const s = Math.max(0, Math.floor(seconds));
        const m = Math.floor(s / 60);
        return `${m}:${String(s % 60).padStart(2, "0")}`;
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.player?.isPlaying ?? false
        onTriggered: root.player.positionChanged()
    }

    Card {
        anchors.fill: parent
        u: root.u
        name: "music"
    }

    Rectangle {
        x: 14 * root.u
        y: 10 * root.u
        width: 64 * root.u
        height: 64 * root.u
        radius: 2 * root.u
        color: Theme.paperDeep
        border.width: Math.max(1, 0.45 * root.u)
        border.color: "#6f6a60"
        clip: true

        Image {
            anchors.fill: parent
            anchors.margins: parent.border.width
            source: root.art !== "" ? root.art : (Config.idleCover !== "" ? `file://${Config.idleCover}` : Theme.asset("cover.png"))
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
            asynchronous: true
        }
    }

    Hand {
        x: 90 * root.u
        y: 13 * root.u
        width: 74 * root.u
        elide: Text.ElideRight
        text: root.idle ? Config.idleTitle : (root.player.trackTitle || "Unknown")
        font.pixelSize: 19 * root.u
        color: Theme.ink
    }

    Hand {
        x: 90 * root.u
        y: 32 * root.u
        width: 74 * root.u
        elide: Text.ElideRight
        text: root.idle ? Config.idleArtist : (root.player.trackArtist || "")
        font.pixelSize: 16 * root.u
        color: Theme.inkFaint
    }

    Hand {
        x: 13 * root.u
        y: 79 * root.u
        text: root.clock(root.position)
        font.pixelSize: 14.5 * root.u
    }

    Rectangle {
        id: track
        x: 38 * root.u
        y: 85.2 * root.u
        width: 92 * root.u
        height: 2.2 * root.u
        radius: height / 2
        color: "#c9c1b3"

        Rectangle {
            width: parent.width * root.fraction
            height: parent.height
            radius: height / 2
            color: Theme.coral
        }

        Rectangle {
            x: parent.width * root.fraction - width / 2
            y: parent.height / 2 - height / 2
            width: 5.4 * root.u
            height: width
            radius: width / 2
            color: Theme.coral
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -5 * root.u
            enabled: root.player?.canSeek ?? false
            cursorShape: Qt.PointingHandCursor
            onClicked: e => root.player.position = root.duration * Math.max(0, Math.min(1, (e.x - 5 * root.u) / track.width))
        }
    }

    Hand {
        x: 136 * root.u
        y: 79 * root.u
        text: root.clock(root.duration)
        font.pixelSize: 14.5 * root.u
    }

    IconButton {
        x: 40 * root.u - box / 2
        y: 112 * root.u - box / 2
        u: root.u
        size: 16 * root.u
        box: 24 * root.u
        icon: "prev"
        onClicked: root.player?.previous()
    }

    IconButton {
        x: 78 * root.u - box / 2
        y: 112 * root.u - box / 2
        u: root.u
        size: 17 * root.u
        box: 24 * root.u
        icon: (root.player?.isPlaying ?? false) || root.idle ? "pause" : "play"
        onClicked: root.player?.togglePlaying()
    }

    IconButton {
        x: 117 * root.u - box / 2
        y: 112 * root.u - box / 2
        u: root.u
        size: 16 * root.u
        box: 24 * root.u
        icon: "next"
        onClicked: root.player?.next()
    }

    IconButton {
        x: 151 * root.u - box / 2
        y: 112 * root.u - box / 2
        u: root.u
        size: 16 * root.u
        box: 24 * root.u
        icon: root.liked ? "heart" : "heart_line"
        onClicked: root.liked = !root.liked
    }
}
