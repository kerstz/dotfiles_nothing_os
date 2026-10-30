import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"
import "../services"

// A month calendar anchored above the clock, bottom-right.
PanelWindow {
    id: win

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nocturne-calendar"
    anchors { top: true; bottom: true; left: true; right: true }

    readonly property bool open: GlobalState.calendarOpen
    mask: Region { item: open ? null : dummy }
    Item { id: dummy }

    // Month being viewed; reset to current each time it opens.
    property int viewYear: Time.now.getFullYear()
    property int viewMonth: Time.now.getMonth()
    onOpenChanged: if (open) { viewYear = Time.now.getFullYear(); viewMonth = Time.now.getMonth(); }

    function step(delta: int): void {
        let m = viewMonth + delta;
        let y = viewYear;
        while (m < 0) { m += 12; y -= 1; }
        while (m > 11) { m -= 12; y += 1; }
        viewMonth = m; viewYear = y;
    }

    // Days laid out Monday-first, with leading blanks.
    readonly property var cells: {
        const first = new Date(viewYear, viewMonth, 1);
        const lead = (first.getDay() + 6) % 7;
        const days = new Date(viewYear, viewMonth + 1, 0).getDate();
        const out = [];
        for (let i = 0; i < lead; i++) out.push(0);
        for (let d = 1; d <= days; d++) out.push(d);
        return out;
    }
    readonly property string title:
        Time.capitalize(new Date(viewYear, viewMonth, 1)
            .toLocaleDateString(Time.locale, "MMMM yyyy"))

    MouseArea {
        anchors.fill: parent
        enabled: win.open
        onClicked: GlobalState.calendarOpen = false
    }

    Frost {
        width: Theme.px(300)
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: Theme.px(10)
        anchors.bottomMargin: Theme.z.bar + Theme.px(14)
        height: col.implicitHeight + Theme.pad * 2
        radius: Theme.r.panel
        alpha: 0.9
        visible: win.open || opacity > 0.01
        opacity: win.open ? 1 : 0
        transform: Translate { y: win.open ? 0 : Theme.px(20)
            Behavior on y { NumberAnimation { duration: Theme.med; easing.type: Theme.ease } } }
        Behavior on opacity { NumberAnimation { duration: Theme.med } }

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: Theme.pad
            spacing: Theme.gap

            Text {
                text: Time.dateLong
                font.family: Theme.f.sans
                font.pixelSize: Theme.f.big
                font.weight: Font.Medium
                color: Theme.c.on
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: win.title
                    font.family: Theme.f.display
                    font.pixelSize: Theme.f.body
                    color: Theme.c.accent2
                    Layout.fillWidth: true
                }
                NavArrow { glyph: ""; onActivated: win.step(-1) }
                NavArrow { glyph: ""; onActivated: win.step(1) }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: Theme.px(2)
                columnSpacing: 0

                Repeater {
                    model: ["M", "T", "W", "T", "F", "S", "S"]
                    delegate: Text {
                        required property var modelData
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.family: Theme.f.sans
                        font.pixelSize: Theme.f.micro
                        font.weight: Font.DemiBold
                        color: Theme.c.onFaint
                    }
                }

                Repeater {
                    model: win.cells
                    delegate: Item {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.px(30)
                        readonly property bool today:
                            modelData === Time.now.getDate()
                            && win.viewMonth === Time.now.getMonth()
                            && win.viewYear === Time.now.getFullYear()
                        Rectangle {
                            anchors.centerIn: parent
                            width: Theme.px(26); height: width
                            radius: width / 2
                            visible: parent.today
                            color: Theme.c.accent
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: modelData > 0
                            text: modelData
                            font.family: Theme.f.sans
                            font.pixelSize: Theme.f.small
                            color: parent.today ? Theme.c.accentInk : Theme.c.on
                        }
                    }
                }
            }
        }
    }

    component NavArrow: Item {
        property string glyph: ""
        signal activated()
        width: Theme.px(26); height: Theme.px(26)
        Rectangle {
            anchors.fill: parent
            radius: Theme.r.tiny
            color: na.containsMouse ? Theme.c.surface3 : "transparent"
        }
        Glyph {
            anchors.centerIn: parent
            text: parent.glyph
            size: Theme.z.icon
            color: Theme.c.onDim
        }
        MouseArea {
            id: na
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.activated()
        }
    }
}
