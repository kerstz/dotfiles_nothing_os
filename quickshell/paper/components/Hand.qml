import QtQuick
import ".."

Text {
    property bool heavy: false
    property bool script: false
    property bool typed: false

    color: Theme.ink
    font.family: script ? Theme.script : (typed ? Theme.mono : Theme.ui)
    font.weight: heavy ? Font.Bold : Font.Normal
    font.hintingPreference: Font.PreferNoHinting
    renderType: Text.QtRendering
    antialiasing: true
    textFormat: Text.PlainText
}
