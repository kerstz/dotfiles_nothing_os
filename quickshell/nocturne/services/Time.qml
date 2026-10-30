pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var locale: Qt.locale("en_GB")
    readonly property date now: clock.date
    readonly property string clockText:
        root.now.toLocaleTimeString(root.locale,
            (Config.twentyFourHour ? "HH:mm" : "h:mm AP")
            + (Config.showSeconds ? ":ss" : ""))
    readonly property string dateText:
        capitalize(root.now.toLocaleDateString(root.locale, "ddd d MMM"))
    readonly property string dateLong:
        capitalize(root.now.toLocaleDateString(root.locale, "dddd d MMMM yyyy"))
    readonly property string monthLong:
        capitalize(root.now.toLocaleDateString(root.locale, "MMMM yyyy"))

    SystemClock {
        id: clock
        precision: Config.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    function capitalize(str: string): string {
        return str.length > 0 ? str.charAt(0).toUpperCase() + str.slice(1) : str;
    }
}
