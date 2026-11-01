import QtQuick
import ".."

Image {
    property string name: ""

    source: Theme.asset(`doodles/${name}.png`)
    fillMode: Image.PreserveAspectFit
    smooth: true
    mipmap: true
    cache: true
}
