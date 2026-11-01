pragma Singleton

import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import ".."

Singleton {
    id: root

    readonly property string folderPath: Config.wallpaperFolder !== "" ? Config.wallpaperFolder : `${Quickshell.env("HOME")}/Images/Wallpapers`
    readonly property url bundled: Theme.asset("wallpaper.png")
    property var items: []

    function rebuild(): void {
        const out = [{ name: "Paper dusk", path: "" }];
        for (let i = 0; i < folder.count; i++) {
            const file = String(folder.get(i, "filePath"));
            if (file.startsWith(`${root.folderPath}/`))
                out.push({ name: String(folder.get(i, "fileName")), path: file });
        }
        root.items = out;
    }

    function set(path: string): void {
        Config.set("wallpaper", path);
    }

    function next(): void {
        if (root.items.length < 2) {
            Sys.notify("Wallpaper", `No pictures in ${root.folderPath}`);
            return;
        }
        let at = root.items.findIndex(i => i.path === Config.wallpaper);
        at = (at + 1) % root.items.length;
        root.set(root.items[at].path);
    }

    FolderListModel {
        id: folder
        folder: "file://" + root.folderPath.split("/").map(encodeURIComponent).join("/")
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
        onCountChanged: root.rebuild()
        onStatusChanged: if (status === FolderListModel.Ready) root.rebuild()
    }

    Component.onCompleted: rebuild()
}
