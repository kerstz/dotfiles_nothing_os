import QtQuick
import ".."

// Classic double-line 3D bevel. raised = button/panel popping out,
// sunken = a well pressed in. Children land on the inner face.
Item {
    id: root

    property color face: Theme.c.face
    property int depth: Theme.edge
    property bool raised: true
    // Flat single-line frame vs full double bevel.
    property bool doubleLine: true

    default property alias content: body.data

    readonly property color _outerTL: raised ? Theme.c.hi : Theme.c.dark
    readonly property color _outerBR: raised ? Theme.c.dark : Theme.c.hi
    readonly property color _innerTL: raised ? Theme.c.faceLit : Theme.c.shadow
    readonly property color _innerBR: raised ? Theme.c.shadow : Theme.c.faceLit

    Rectangle { anchors.fill: parent; color: root.face }

    // Outer bevel
    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: root.depth; color: root._outerTL }
    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.bottom: parent.bottom; width: root.depth; color: root._outerTL }
    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: root.depth; color: root._outerBR }
    Rectangle { anchors.top: parent.top; anchors.right: parent.right; anchors.bottom: parent.bottom; width: root.depth; color: root._outerBR }

    // Inner bevel
    Rectangle { visible: root.doubleLine; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.topMargin: root.depth; anchors.leftMargin: root.depth; anchors.rightMargin: root.depth; height: root.depth; color: root._innerTL }
    Rectangle { visible: root.doubleLine; anchors.top: parent.top; anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.topMargin: root.depth; anchors.leftMargin: root.depth; anchors.bottomMargin: root.depth; width: root.depth; color: root._innerTL }
    Rectangle { visible: root.doubleLine; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; anchors.leftMargin: root.depth; anchors.rightMargin: root.depth; anchors.bottomMargin: root.depth; height: root.depth; color: root._innerBR }
    Rectangle { visible: root.doubleLine; anchors.top: parent.top; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.topMargin: root.depth; anchors.rightMargin: root.depth; anchors.bottomMargin: root.depth; width: root.depth; color: root._innerBR }

    Item {
        id: body
        anchors.fill: parent
        anchors.margins: root.doubleLine ? root.depth * 2 : root.depth
    }
}
