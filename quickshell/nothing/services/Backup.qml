pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// Backing up files to another disk, for Settings > System > Disk backup.
// The work is scripts/backup-disk.sh (rsync, snapshots, pruning, dest
// safety); this drives it and reports progress. One run at a time.
//
// Profiles choose what: "session" is the whole home (caches and trashes
// left out), "config" the dotfiles and setup, "documents" the personal
// folders, "custom" the folders you list. The destination is whatever
// disk you point it at; an encrypted one is unlocked through Drives first.
Singleton {
    id: root

    readonly property string script: Quickshell.shellPath("../../scripts/backup-disk.sh")

    property var profiles: []          // [{ key, has, count }]
    property bool running: false
    property real progress: -1         // 0..1 while copying, -1 otherwise
    property string status: ""
    property string lastSnapshot: ""
    property var snapshots: []          // [{ name, bytes }]
    property var plan: null             // { files, bytes } or null

    readonly property string profile: Config.backupDiskProfile
    readonly property string dest: Config.backupDiskDest
    readonly property var custom: Config.backupDiskCustom ?? []

    readonly property var profileMeta: ({
        session:   { label: "User session", words: "the whole home folder, minus caches and trash" },
        config:    { label: "Config & dotfiles", words: "~/.config, setup files and keys" },
        documents: { label: "Documents", words: "Documents, Pictures, Music, Videos, Desktop" },
        custom:    { label: "Chosen folders", words: "the folders you add below" }
    })

    function has(key: string): bool {
        if (key === "custom")
            return root.custom.length > 0;
        const p = root.profiles.find(x => x.key === key);
        return p ? p.has : false;
    }

    // Extra argv for the "custom" profile: the chosen folders. Empty for
    // the others, which know their own paths.
    function pathArgs(): var {
        return root.profile === "custom" ? root.custom.slice() : [];
    }

    function human(bytes: real): string {
        if (!bytes || bytes < 1)
            return "0 B";
        const u = ["B", "KB", "MB", "GB", "TB"];
        let i = 0, v = bytes;
        while (v >= 1000 && i < u.length - 1) { v /= 1000; i++; }
        return (v >= 10 || i === 0 ? Math.round(v) : v.toFixed(1)) + " " + u[i];
    }

    // ── Probing ───────────────────────────────────────────────────────
    function refresh(): void {
        probe.running = false;
        probe.running = true;
        root.refreshSnapshots();
    }

    NProcess {
        id: probe
        label: "backup profiles"
        command: ["bash", root.script, "profiles"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.profiles = JSON.parse(text); } catch (e) {}
            }
        }
    }

    function refreshSnapshots(): void {
        if (root.dest === "")
            { root.snapshots = []; return; }
        snaps.command = ["bash", root.script, "snapshots", root.profile, root.dest];
        snaps.running = false;
        snaps.running = true;
    }

    NProcess {
        id: snaps
        quiet: true
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.snapshots = JSON.parse(text); } catch (e) { root.snapshots = []; }
            }
        }
    }

    // ── Estimate (dry run) ────────────────────────────────────────────
    function estimate(): void {
        if (root.running || root.dest === "")
            return;
        root.plan = null;
        root.status = "Estimating…";
        planner.command = ["bash", root.script, "plan", root.profile, root.dest]
                          .concat(root.pathArgs());
        planner.running = false;
        planner.running = true;
    }

    NProcess {
        id: planner
        stdout: StdioCollector { id: planOut }
        stderr: StdioCollector { id: planErr }
        onExited: (code) => {
            if (code === 0) {
                try {
                    root.plan = JSON.parse(planOut.text);
                    root.status = "About " + root.human(root.plan.bytes) + " to copy"
                        + (root.plan.files > 0 ? " (" + root.plan.files + " files changed)" : "");
                } catch (e) { root.status = "Could not estimate"; }
            } else {
                root.status = planErr.text.trim().split("\n").pop() || "Could not estimate";
            }
        }
    }

    // ── Running ───────────────────────────────────────────────────────
    function start(): void {
        if (root.running || root.dest === "")
            return;
        if (root.profile === "custom" && root.custom.length === 0) {
            root.status = "Add at least one folder first";
            return;
        }
        root.running = true;
        root.progress = 0;
        root.status = "Backing up…";
        root.lastSnapshot = "";
        runner.command = ["bash", root.script, "run", root.profile, root.dest,
                          String(Math.max(0, Config.backupDiskKeep))]
                         .concat(root.pathArgs());
        runner.running = false;
        runner.running = true;
    }

    NProcess {
        id: runner
        label: "backup"
        // rsync --info=progress2 updates the overall percentage on carriage
        // returns, so the stream is split on \r rather than \n.
        stdout: SplitParser {
            splitMarker: "\r"
            onRead: (chunk) => {
                const pct = String(chunk).match(/(\d+)%/);
                if (pct)
                    root.progress = Math.min(1, parseInt(pct[1], 10) / 100);
                const done = String(chunk).match(/DONE (\S+)/);
                if (done)
                    root.lastSnapshot = done[1];
            }
        }
        stderr: StdioCollector { id: runErr }
        onExited: (code) => {
            root.running = false;
            root.progress = -1;
            // The script keeps a partial-file exit (23/24) as success and
            // returns 0; anything else is a real failure.
            if (code === 0) {
                root.status = root.lastSnapshot !== ""
                    ? "Backed up — snapshot " + root.lastSnapshot
                    : "Backed up";
            } else {
                root.status = "Failed: "
                    + (runErr.text.trim().split("\n").pop() || ("rsync exit " + code));
                console.warn("backup: " + root.status);
            }
            root.refreshSnapshots();
        }
    }

    Component.onCompleted: root.refresh()
}
