pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property bool startOpen: false
    function toggleStart(): void { startOpen = !startOpen; }
}
