import QtQuick
import ".."

Image {
    property string tone: "tan"

    source: Theme.asset(`paper/tape_${tone}.png`)
    smooth: true
    mipmap: true
    cache: true
}
