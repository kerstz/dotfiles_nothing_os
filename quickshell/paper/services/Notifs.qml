pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import ".."

Singleton {
    id: root

    property var popups: []
    property var history: []

    function dropPopup(n: var): void {
        root.popups = root.popups.filter(i => i !== n);
    }

    function dismiss(n: var): void {
        root.dropPopup(n);
        root.history = root.history.filter(i => i.source !== n);
        n.dismiss();
    }

    function clearAll(): void {
        const list = root.history;
        root.history = [];
        root.popups = [];
        for (let i = 0; i < list.length; i++)
            list[i].source?.dismiss();
    }

    NotificationServer {
        keepOnReload: false
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        onNotification: n => {
            n.tracked = true;
            root.history = [{ summary: n.summary, body: n.body, appName: n.appName, source: n, time: new Date() }].concat(root.history).slice(0, 60);
            if (!Config.dnd && !Sys.game)
                root.popups = [n].concat(root.popups).slice(0, 4);
        }
    }
}
