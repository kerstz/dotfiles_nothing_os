pragma Singleton

import QtQuick
import Quickshell

// Resolve applications through the system's .desktop files, for real
// icons and names rather than guessed glyphs.
Singleton {
    id: root

    readonly property var all: DesktopEntries.applications?.values ?? []
    readonly property var visible: root.all
        .filter(e => !e.noDisplay)
        .sort((x, y) => x.name.localeCompare(y.name))

    function entry(id: string): var {
        if (!id) return null;
        const tries = [id, id.toLowerCase()];
        for (let i = 0; i < tries.length; i++) {
            const e = DesktopEntries.byId(tries[i]);
            if (e) return e;
        }
        const lower = id.toLowerCase();
        for (let i = 0; i < root.all.length; i++) {
            const e = root.all[i];
            if ((e.startupClass ?? "").toLowerCase() === lower
                || (e.id ?? "").toLowerCase() === lower)
                return e;
        }
        for (let i = 0; i < tries.length; i++) {
            const e = DesktopEntries.heuristicLookup(tries[i]);
            if (e) return e;
        }
        return null;
    }

    function iconFor(id: string): string {
        const e = root.entry(id);
        const name = e?.icon ?? id;
        if (!name) return "";
        if (name.startsWith("/")) return "file://" + name;
        if (name.includes("://")) return name;
        if (Quickshell.hasThemeIcon(name))
            return Quickshell.iconPath(name);
        return Quickshell.iconPath(name, true);
    }

    function nameFor(id: string): string { return root.entry(id)?.name ?? id; }

    function classFor(id: string): string {
        const e = root.entry(id);
        return (e?.startupClass || e?.id || id).toLowerCase();
    }

    function launch(id: string): void {
        const e = root.entry(id);
        if (e) e.execute();
    }

    function search(query: string): var {
        const q = query.trim().toLowerCase();
        if (q === "") return root.visible;
        return root.visible.filter(e =>
            e.name.toLowerCase().includes(q)
            || (e.genericName ?? "").toLowerCase().includes(q)
            || (e.comment ?? "").toLowerCase().includes(q)
            || (e.id ?? "").toLowerCase().includes(q));
    }
}
