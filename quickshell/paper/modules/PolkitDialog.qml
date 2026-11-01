import QtQuick
import Quickshell.Services.Polkit
import ".."
import "../components"

OverlayPanel {
    id: win

    readonly property var flow: agent.flow

    open: GlobalState.polkitOpen && agent.isActive && flow !== null
    panelWidth: 330
    panelHeight: 200
    tape: "pink"
    onDismissed: win.cancel()

    function cancel(): void {
        win.flow?.cancelAuthenticationRequest();
        GlobalState.polkitOpen = false;
    }

    PolkitAgent {
        id: agent
        onAuthenticationRequestStarted: GlobalState.polkitOpen = true
    }

    Connections {
        target: win.flow
        ignoreUnknownSignals: true
        function onAuthenticationSucceeded(): void {
            GlobalState.polkitOpen = false;
        }
        function onAuthenticationRequestCancelled(): void {
            GlobalState.polkitOpen = false;
        }
        function onIsResponseRequiredChanged(): void {
            answer.forceActiveFocus();
        }
    }

    onVisibleChanged: {
        if (visible) {
            answer.text = "";
            answer.forceActiveFocus();
        }
    }

    Hand {
        x: 16 * win.u
        y: 10 * win.u
        script: true
        text: "Permission needed"
        font.pixelSize: 21 * win.u
    }

    Hand {
        x: 16 * win.u
        y: 42 * win.u
        width: parent.width - 32 * win.u
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight
        text: win.flow?.message ?? ""
        font.pixelSize: 15.5 * win.u
        color: Theme.inkSoft
    }

    Rectangle {
        x: 16 * win.u
        y: 104 * win.u
        width: parent.width - 32 * win.u
        height: 26 * win.u
        radius: 5 * win.u
        color: Theme.paperLight
        border.width: Math.max(1, 0.6 * win.u)
        border.color: (win.flow?.supplementaryIsError ?? false) ? Theme.red : Theme.inkSoft

        TextInput {
            id: answer
            anchors.fill: parent
            anchors.leftMargin: 8 * win.u
            anchors.rightMargin: 8 * win.u
            verticalAlignment: TextInput.AlignVCenter
            echoMode: (win.flow?.responseVisible ?? false) ? TextInput.Normal : TextInput.Password
            passwordCharacter: "*"
            clip: true
            color: Theme.ink
            font.family: Theme.ui
            font.pixelSize: 17 * win.u
            onAccepted: {
                win.flow?.submit(text);
                text = "";
            }
            Keys.onEscapePressed: win.cancel()
        }
    }

    Hand {
        x: 16 * win.u
        y: 134 * win.u
        width: parent.width - 32 * win.u
        elide: Text.ElideRight
        text: win.flow?.supplementaryMessage ?? ""
        font.pixelSize: 14 * win.u
        color: (win.flow?.supplementaryIsError ?? false) ? Theme.red : Theme.inkFaint
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 16 * win.u
        y: 158 * win.u
        spacing: 7 * win.u

        PaperButton {
            u: win.u
            label: "Cancel"
            onClicked: win.cancel()
        }

        PaperButton {
            u: win.u
            label: "Allow"
            tone: Theme.blueSoft
            onClicked: {
                win.flow?.submit(answer.text);
                answer.text = "";
            }
        }
    }
}
