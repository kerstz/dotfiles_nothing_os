pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pam

Singleton {
    id: root

    readonly property bool locked: persisted.locked
    property string secret: ""
    property bool busy: false
    property string notice: ""
    property int shake: 0

    function activate(): void {
        root.reset();
        persisted.locked = true;
    }

    function submit(): void {
        if (root.busy || root.secret === "")
            return;
        root.busy = true;
        root.notice = "";
        pam.start();
    }

    function reset(): void {
        root.secret = "";
        root.busy = false;
        root.notice = "";
    }

    PersistentProperties {
        id: persisted
        reloadableId: "paperLock"
        property bool locked: false
    }

    Timer {
        interval: 30000
        running: root.locked && root.secret !== "" && !root.busy
        onTriggered: root.secret = ""
    }

    PamContext {
        id: pam

        onPamMessage: {
            if (pam.responseRequired)
                pam.respond(root.secret);
        }

        onCompleted: result => {
            root.busy = false;
            root.secret = "";
            if (result === PamResult.Success) {
                root.notice = "";
                persisted.locked = false;
                return;
            }
            root.shake++;
            root.notice = result === PamResult.MaxTries ? "Too many attempts" : "Wrong password";
        }

        onError: error => {
            root.busy = false;
            root.secret = "";
            root.shake++;
            root.notice = "Could not check the password";
        }
    }
}
