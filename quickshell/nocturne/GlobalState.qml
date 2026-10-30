pragma Singleton

import QtQuick
import Quickshell

// Shared state across the shell's Wayland windows.
Singleton {
    id: root

    property bool startOpen: false
    property bool powerOpen: false
    property bool calendarOpen: false
    // Pre-filled search when the start menu opens.
    property string startQuery: ""

    function toggleStart(): void {
        if (root.startOpen) { root.startOpen = false; return; }
        root.closeAll();
        root.startQuery = "";
        root.startOpen = true;
    }

    function togglePower(): void {
        const was = root.powerOpen;
        root.closeAll();
        root.powerOpen = !was;
    }

    function toggleCalendar(x: real): void {
        const was = root.calendarOpen;
        root.closeAll();
        root.calendarOpen = !was;
    }

    function closeAll(): void {
        root.startOpen = false;
        root.powerOpen = false;
        root.calendarOpen = false;
    }
}
