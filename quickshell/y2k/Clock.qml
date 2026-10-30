pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    readonly property var locale: Qt.locale("en_GB")
    readonly property date now: sysClock.date
    readonly property string hhmm: now.toLocaleString(locale, "HH:mm")
    readonly property string ampm: now.toLocaleString(locale, "h:mm AP")
    readonly property string dateLong: cap(now.toLocaleDateString(locale, "dddd, d MMMM yyyy"))

    SystemClock { id: sysClock; precision: SystemClock.Seconds }

    function cap(s: string): string {
        return s.length > 0 ? s.charAt(0).toUpperCase() + s.slice(1) : s;
    }
}
