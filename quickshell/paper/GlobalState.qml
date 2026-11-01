pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool launcherOpen: false
    property bool sessionOpen: false
    property bool filesOpen: false
    property string filesPath: ""
    property bool controlOpen: false
    property bool notifOpen: false
    property bool clipboardOpen: false
    property bool emojiOpen: false
    property bool cheatsheetOpen: false
    property bool wallpaperOpen: false
    property bool notesOpen: false
    property bool settingsOpen: false
    property string settingsPage: "look"
    property bool polkitOpen: false

    function openFiles(path: string): void {
        if (path !== "")
            root.filesPath = path;
        root.filesOpen = true;
    }

    function openSettings(page: string): void {
        if (page !== "")
            root.settingsPage = page;
        root.settingsOpen = true;
    }

    function toggleSettings(page: string): void {
        if (root.settingsOpen && (page === "" || root.settingsPage === page))
            root.settingsOpen = false;
        else
            root.openSettings(page);
    }
}
