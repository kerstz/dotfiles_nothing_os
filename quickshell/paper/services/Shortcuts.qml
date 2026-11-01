pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property var groups: [
        { title: "Apps", items: [
            ["SUPER + Return / T", "Terminal"], ["SUPER + E", "Files"], ["SUPER + W", "Browser"],
            ["SUPER + C", "Code editor"], ["SUPER + X", "Text editor"], ["CTRL + SUPER + V", "Volume mixer"]
        ] },
        { title: "Shell", items: [
            ["SUPER", "Launcher"], ["SUPER + R / Tab", "Launcher"], ["SUPER + I", "Settings"], ["SUPER + ALT + L", "Control centre"],
            ["SUPER + B", "Notifications"], ["SUPER + V", "Clipboard"], ["SUPER + Period", "Emoji"], ["SUPER + A", "Notes board"],
            ["SUPER + N", "Hide or show the bar"], ["SUPER + Slash", "This sheet"], ["CTRL + SUPER + R", "Reload the shell"], ["SUPER + ALT + R", "Next rice"]
        ] },
        { title: "Look", items: [
            ["SUPER + SHIFT + T", "Wallpaper picker"], ["SUPER + ALT + W", "Next wallpaper"], ["SUPER + P", "Screens"],
            ["SUPER + ALT + B", "Night light"], ["SUPER + ALT + I", "Keep awake"], ["SUPER + - / =", "Zoom"]
        ] },
        { title: "Windows", items: [
            ["SUPER + Q", "Close"], ["SUPER + F", "Fullscreen"], ["SUPER + D", "Maximise"], ["SUPER + ALT + Space", "Float"],
            ["SUPER + Arrows", "Focus"], ["SUPER + SHIFT + Arrows", "Move"], ["SUPER + mouse", "Drag or resize"], ["SUPER + SHIFT + ALT + P", "Pin"]
        ] },
        { title: "Workspaces", items: [
            ["SUPER + 1-0", "Go to workspace"], ["SUPER + ALT + 1-0", "Send window"], ["CTRL + SUPER + Left/Right", "Previous, next"],
            ["SUPER + S", "Scratchpad"], ["SUPER + ALT + S", "Send to scratchpad"]
        ] },
        { title: "Capture", items: [
            ["SUPER + SHIFT + S", "Screenshot region"], ["Print", "Screenshot screen"], ["CTRL + Print", "Save screenshot"],
            ["SUPER + SHIFT + X", "Text from screen"], ["SUPER + SHIFT + C", "Colour picker"], ["SUPER + SHIFT + R", "Record region"],
            ["CTRL + ALT + R", "Record screen"], ["SUPER + SHIFT + ALT + R", "Record with sound"], ["SUPER + SHIFT + A", "Image search"], ["SUPER + ALT + N", "Recognise song"]
        ] },
        { title: "Media", items: [
            ["SUPER + SHIFT + P", "Play or pause"], ["SUPER + SHIFT + N", "Next"], ["SUPER + SHIFT + B", "Previous"],
            ["SUPER + SHIFT + M", "Mute"], ["SUPER + ALT + M", "Mute microphone"]
        ] },
        { title: "Session", items: [
            ["SUPER + L", "Lock"], ["SUPER + SHIFT + L", "Suspend"], ["SUPER + Escape", "Session menu"], ["CTRL + ALT + Delete", "Session menu"],
            ["CTRL + SHIFT + Escape", "Processes"], ["SUPER + G", "Game mode"], ["SUPER + ALT + X", "Crosshair"]
        ] }
    ]
}
