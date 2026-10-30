import QtQuick
import ".."

// Thin sunken vertical separator: a dark line then a light one.
Item {
    implicitWidth: Theme.px(3)
    Rectangle { anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 1; color: Theme.c.shadow }
    Rectangle { anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 1; color: Theme.c.hi }
}
