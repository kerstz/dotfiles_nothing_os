import QtQuick
import ".."

// A Nerd Font icon.
Text {
    property real size: Theme.z.icon
    font.family: Theme.f.glyphs
    font.pixelSize: size
    color: Theme.c.on
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
