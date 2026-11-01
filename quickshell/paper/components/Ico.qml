import QtQuick
import ".."

Image {
    property string name: ""
    property real size: 16

    width: size
    height: size
    source: name === "" ? "" : Theme.icon(name)
    fillMode: Image.PreserveAspectFit
    smooth: true
    mipmap: true
    cache: true
}
