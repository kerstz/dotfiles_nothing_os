pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// USB sticks, SD cards and external disks: mounted when plugged in, said
// so in a notification, listed in the control centre with Open and Eject.
//
// udisks does the work (udisksctl), as a file manager would: mounting a
// removable drive as the logged-in user is allowed by its own polkit rules,
// so there is no sudo and no fstab edit. The list is lsblk's, re-read when
// udev reports a block device appearing, changing or going away, never on a
// timer. Only drives plugged in while the shell runs are mounted on their
// own; one already there at login is listed and left alone, as is anything
// encrypted (the file manager asks for its passphrase).
Singleton {
    id: root

    property bool available: false     // udisksctl present
    // [{ path, disk, label, size, fstype, mount, encrypted }]
    property var list: []
    readonly property var mounted: root.list.filter(d => d.mount !== "")
    property var known: ({})           // path -> true, what has been seen
    property bool primed: false

    NProcess {
        id: probe
        quiet: true
        running: true
        command: ["sh", "-c", "command -v udisksctl >/dev/null && command -v lsblk >/dev/null && echo yes"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.available = text.trim() === "yes";
                if (root.available) {
                    root.refresh();
                    watcher.running = true;
                }
            }
        }
    }

    // One long-lived process, events only.
    NProcess {
        id: watcher
        quiet: true
        command: ["udevadm", "monitor", "--udev", "--subsystem-match=block"]
        stdout: SplitParser {
            onRead: (line) => {
                if (/\s(add|remove|change)\s/.test(line))
                    settle.restart();
            }
        }
    }

    // A plug-in is a burst of events (disk, then each partition).
    Timer { id: settle; interval: 700; onTriggered: root.refresh() }

    function refresh(): void {
        lister.running = false;
        lister.running = true;
    }

    function human(bytes: real): string {
        const u = ["B", "KB", "MB", "GB", "TB"];
        let i = 0, v = bytes;
        while (v >= 1000 && i < u.length - 1) { v /= 1000; i++; }
        return (v >= 10 || i === 0 ? Math.round(v) : v.toFixed(1)) + " " + u[i];
    }

    NProcess {
        id: lister
        label: "drives"
        command: ["lsblk", "-J", "-b", "-o",
                  "PATH,LABEL,SIZE,FSTYPE,MOUNTPOINT,RM,HOTPLUG,TYPE,TRAN,PKNAME"]
        stdout: StdioCollector {
            onStreamFinished: {
                let tree;
                try { tree = JSON.parse(text); } catch (e) { return; }
                const out = [];
                const walk = (nodes, tran, removable) => {
                    for (const n of nodes ?? []) {
                        // The bus is on the disk, not on its partitions.
                        const t = n.tran ?? tran;
                        const r = removable || n.rm === true || n.rm === "1"
                                  || n.hotplug === true || n.hotplug === "1";
                        if (r && (t === "usb" || t === "mmc" || t === null || t === undefined)
                            && n.fstype && n.fstype !== "swap"
                            && (n.type === "part" || n.type === "disk")) {
                            // A LUKS partition carries its unlocked filesystem
                            // as a "crypt" child: once unlocked, that child is
                            // what gets mounted, and locking closes it again.
                            const enc = n.fstype === "crypto_LUKS";
                            const clear = enc
                                ? (n.children ?? []).find(c => c.type === "crypt") : null;
                            out.push({
                                path: n.path,
                                disk: n.pkname ? "/dev/" + n.pkname : n.path,
                                label: n.label || n.path.split("/").pop(),
                                size: root.human(Number(n.size) || 0),
                                fstype: n.fstype,
                                encrypted: enc,
                                unlocked: enc && clear !== undefined && clear !== null,
                                clear: clear ? clear.path : "",
                                mount: enc ? (clear?.mountpoint ?? "") : (n.mountpoint ?? "")
                            });
                        }
                        walk(n.children, t, r);
                    }
                };
                walk(tree.blockdevices, null, false);
                root.arrived(out);
                root.list = out;
            }
        }
    }

    function arrived(now: var): void {
        const seen = Object.assign({}, root.known);
        for (const d of now) {
            if (seen[d.path])
                continue;
            seen[d.path] = true;
            // The first read is what was there at login: listed, not mounted.
            if (!root.primed)
                continue;
            if (d.encrypted && !d.unlocked)
                root.notify(d.label + " plugged in", "Encrypted — unlock it to use it");
            else if (!d.encrypted && d.mount === "" && Config.drivesAutomount)
                root.mount(d.path);
            else
                root.notify(d.label + " plugged in", d.size + (d.mount !== "" ? " · " + d.mount : ""));
        }
        // Gone ones are forgotten, so plugging it back in counts as new.
        for (const p in seen)
            if (!now.some(d => d.path === p))
                delete seen[p];
        root.known = seen;
        root.primed = true;
    }

    function notify(title: string, body: string): void {
        if (!Config.drivesNotify)
            return;
        Quickshell.execDetached(["notify-send", "-a", "Nothing", "-i", "drive-removable-media",
                                 title, body]);
    }

    // ── Actions, one at a time ────────────────────────────────────────
    property string busyPath: ""

    function mount(path: string): void {
        root.run("mount", path, ["udisksctl", "mount", "-b", path, "--no-user-interaction"]);
    }

    function open(d: var): void {
        if (d.mount !== "")
            Quickshell.execDetached(["xdg-open", d.mount]);
        else if (d.encrypted && d.unlocked && d.clear !== "")
            root.mount(d.clear);
        else if (!d.encrypted)
            root.mount(d.path);
    }

    // Unlock a LUKS drive and mount it. The passphrase is written to
    // udisksctl's stdin (it reads it there when stdin is not a terminal),
    // never put on the command line where ps would show it, and dropped as
    // soon as it is sent. udisksctl's own polkit rule lets the logged-in
    // user do this, so there is no sudo.
    property string unlockFor: ""
    property string unlockError: ""
    function unlock(path: string, passphrase: string): void {
        if (unlocker.running || passphrase === "")
            return;
        root.unlockFor = path;
        root.unlockError = "";
        unlocker.target = path;
        unlocker.pass = passphrase;
        unlocker.command = ["udisksctl", "unlock", "-b", path];
        unlocker.stdinEnabled = true;   // so the passphrase can be written
        unlocker.running = true;
    }

    NProcess {
        id: unlocker
        quiet: true
        property string target: ""
        property string pass: ""
        stderr: StdioCollector { id: unlockErr }
        onRunningChanged: {
            if (running) {
                write(unlocker.pass + "\n");
                unlocker.pass = "";       // gone the moment it is sent
                stdinEnabled = false;
            }
        }
        onExited: (code) => {
            root.unlockFor = "";
            unlocker.pass = "";       // defensive: in case running never toggled
            if (code !== 0) {
                const why = (unlockErr.text.trim().split("\n").pop() || ("exit " + code))
                    .replace(/^Error [^:]*: ?/, "");
                root.unlockError = /pass|wrong|decrypt/i.test(why)
                    ? "Wrong passphrase" : why;
            } else {
                // Mount the filesystem that unlocking just exposed.
                root.refresh();
                unlockSettle.restart();
            }
        }
    }

    // After an unlock the cleartext device appears a moment later; mount it
    // once the list has caught up.
    Timer {
        id: unlockSettle
        interval: 500
        onTriggered: {
            const d = root.list.find(x => x.path === unlocker.target);
            if (d && d.unlocked && d.clear !== "" && d.mount === "")
                root.mount(d.clear);
        }
    }

    function lock(d: var): void {
        if (!d.encrypted)
            return;
        // Unmount the open filesystem first, then close the LUKS device.
        const script = '[ -n "$2" ] && udisksctl unmount -b "$2" --no-user-interaction 2>/dev/null; '
                     + 'udisksctl lock -b "$1"';
        root.run("lock", d.path, ["sh", "-c", script, "lock", d.path, d.clear]);
    }

    // Unmount every mounted partition of the same disk, then power the
    // disk off: once that answers, pulling the cable is safe.
    function eject(d: var): void {
        const onDisk = root.list.filter(x => x.disk === d.disk);
        // Unmount every mounted filesystem (the cleartext child for an
        // unlocked LUKS), then lock each LUKS mapping, then power off: a
        // still-open mapping holds the disk and power-off would be refused.
        const unmounts = onDisk.filter(x => x.mount !== "")
            .map(x => (x.encrypted && x.unlocked) ? x.clear : x.path);
        const locks = onDisk.filter(x => x.encrypted && x.unlocked).map(x => x.path);
        // Counts rather than a sentinel, so a path could never be mistaken
        // for the "--" marker.
        const script = 'disk="$1"; shift; n="$1"; shift; '
                     + 'while [ "$n" -gt 0 ]; do udisksctl unmount -b "$1" --no-user-interaction || true; shift; n=$((n-1)); done; '
                     + 'n="$1"; shift; while [ "$n" -gt 0 ]; do udisksctl lock -b "$1" || exit 1; shift; n=$((n-1)); done; '
                     + 'udisksctl power-off -b "$disk" --no-user-interaction';
        root.run("eject", d.disk, ["sh", "-c", script, "eject", d.disk,
                                   String(unmounts.length)].concat(unmounts,
                                   [String(locks.length)], locks));
    }

    // One udisksctl at a time; the rest wait their turn (a disk with two
    // partitions mounts both, not just the first).
    property var waiting: []

    function run(kind: string, path: string, cmd: var): void {
        if (actor.running || root.busyPath !== "") {
            root.waiting = root.waiting.concat([{ kind: kind, path: path, cmd: cmd }]);
            return;
        }
        root.busyPath = path;
        actor.kind = kind;
        actor.target = path;
        actor.command = cmd;
        actor.running = true;
    }

    NProcess {
        id: actor
        quiet: true
        property string kind: ""
        property string target: ""
        stdout: StdioCollector { id: actOut }
        stderr: StdioCollector { id: actErr }
        onExited: (code) => {
            const d = root.list.find(x => x.path === actor.target || x.disk === actor.target);
            const name = d?.label ?? actor.target;
            root.busyPath = "";
            if (code !== 0) {
                // "target is busy" is the usual one: a file still open.
                const why = (actErr.text.trim().split("\n").pop() || ("exit " + code))
                    .replace(/^Error [^:]*: ?/, "");
                console.warn("drives: " + actor.kind + " " + actor.target + ": " + why);
                Quickshell.execDetached(["notify-send", "-a", "Nothing", "-u", "critical",
                    (actor.kind === "eject" ? "Cannot eject " : "Cannot mount ") + name,
                    /busy/i.test(why) ? "Something still has a file open on it. Close it and try again." : why]);
            } else if (actor.kind === "lock") {
                root.notify(name + " locked", "The encrypted drive is closed");
            } else if (actor.kind === "eject") {
                root.notify(name + " can be removed", "Unmounted and powered off");
            } else {
                const at = (actOut.text.match(/ at (.+?)\.?\s*$/m) ?? [])[1] ?? "";
                root.notify(name + " mounted", (d?.size ?? "") + (at !== "" ? " · " + at : ""));
            }
            root.refresh();
            if (root.waiting.length > 0) {
                const n = root.waiting[0];
                root.waiting = root.waiting.slice(1);
                Qt.callLater(() => root.run(n.kind, n.path, n.cmd));
            }
        }
    }
}
