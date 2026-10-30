import QtQuick
import Quickshell
import ".."

// Resolve an icon-theme name (or window class) to an image, with a loud
// chrome-square fallback carrying the app's first letter.
Item {
    id: root
    property string name: ""
    property string fallbackText: ""
    property real size: Theme.z.icon

    implicitWidth: size
    implicitHeight: size

    readonly property var candidates: {
        const out = [];
        const n = root.name;
        if (!n) return out;
        if (n.startsWith("image://") || n.startsWith("qrc:") || n.startsWith("/") || n.includes("://")) {
            out.push(n);
            return out;
        }
        const p1 = Quickshell.iconPath(n, true);
        if (p1) out.push(p1);
        const p2 = Quickshell.iconPath(n.toLowerCase(), true);
        if (p2) out.push(p2);
        const p3 = Quickshell.iconPath(n.split(".").pop().toLowerCase(), true);
        if (p3) out.push(p3);
        return out;
    }

    property int idx: 0
    onCandidatesChanged: idx = 0
    onNameChanged: idx = 0

    readonly property string resolved: (idx < candidates.length) ? candidates[idx] : ""

    Image {
        id: img
        anchors.fill: parent
        source: root.resolved
        sourceSize.width: Math.round(root.size * 2)
        sourceSize.height: Math.round(root.size * 2)
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: false
        visible: status === Image.Ready && root.resolved !== ""
        onStatusChanged: if (status === Image.Error && root.idx < root.candidates.length - 1) root.idx++
    }

    Rectangle {
        anchors.fill: parent
        visible: !img.visible
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.c.cyan }
            GradientStop { position: 1.0; color: Theme.c.violet }
        }
        border.width: 1
        border.color: Theme.c.dark
        Text {
            anchors.centerIn: parent
            text: (root.fallbackText.length > 0 ? root.fallbackText[0] : (root.name.length > 0 ? root.name[0] : "?")).toUpperCase()
            color: "#ffffff"
            font.family: Theme.f.arcade
            font.pixelSize: root.size * 0.5
            renderType: Text.NativeRendering
        }
    }
}
