import QtQuick
import ".."

// A frosted translucent panel: a violet-tinted surface over the wallpaper,
// a hairline violet rim, a soft inner lift. Hyprland's blur sits behind.
Rectangle {
    id: root
    property real alpha: 0.82
    property color tintColor: Theme.c.surface
    radius: Theme.r.panel
    color: Theme.tint(tintColor, alpha)
    border.width: 1
    border.color: Theme.tint(Theme.c.accent, 0.22)

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        color: "transparent"
        border.width: 1
        border.color: Theme.tint("#ffffff", 0.04)
    }
}
