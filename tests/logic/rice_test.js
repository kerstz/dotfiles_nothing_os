// rice switcher: run the real scripts/rice.sh in a throwaway root with no
// Hyprland session, so set/next only record the choice (never touch qs).
//   node rice_test.js ../../scripts/rice.sh
const fs = require("fs"), os = require("os"), path = require("path");
const assert = require("assert"), { spawnSync } = require("child_process");

const script = path.resolve(process.argv[2]);
const root = fs.mkdtempSync(path.join(os.tmpdir(), "rice-"));
fs.mkdirSync(path.join(root, "scripts"));
fs.copyFileSync(script, path.join(root, "scripts", "rice.sh"));
const mkRice = (n) => {
    fs.mkdirSync(path.join(root, "quickshell", n), { recursive: true });
    fs.writeFileSync(path.join(root, "quickshell", n, "shell.qml"), "// fake\n");
};
mkRice("nothing");
mkRice("glacier");
fs.mkdirSync(path.join(root, "quickshell", "scratch"), { recursive: true }); // no shell.qml

const state = path.join(root, "state");
const run = (...args) => {
    const env = Object.assign({}, process.env, { HOME: root, XDG_STATE_HOME: state });
    delete env.HYPRLAND_INSTANCE_SIGNATURE;
    delete env.WAYLAND_DISPLAY;
    const r = spawnSync("bash", [path.join(root, "scripts", "rice.sh"), ...args],
        { env, encoding: "utf8" });
    return { status: r.status, out: r.stdout.trim(), err: r.stderr.trim() };
};
const stateFile = () => fs.readFileSync(path.join(state, "nothing", "rice"), "utf8").trim();

// list: only dirs carrying shell.qml, sorted, scratch excluded.
assert.strictEqual(run("list").out, "glacier\nnothing", "list sorted, shell.qml only");

// current with no state file resolves to the default.
assert.strictEqual(run("current").out, "nothing", "default current");

// unknown name refused cleanly, nothing written.
const bad = run("set", "bogus");
assert.notStrictEqual(bad.status, 0, "unknown rice exits nonzero");
assert.ok(!fs.existsSync(path.join(state, "nothing", "rice")), "refused set writes nothing");
assert.ok(/unknown rice/.test(bad.err), "says what was wrong");

// set writes the state file and resolves back out of it; no session so it
// reports the save rather than a live apply.
const set = run("set", "glacier");
assert.strictEqual(set.status, 0, "valid set succeeds");
assert.strictEqual(stateFile(), "glacier", "state file holds the name");
assert.ok(/next login/.test(set.out), "no session -> saved, not applied");
assert.strictEqual(run("current").out, "glacier", "current reads the state file");

// next cycles in sorted order and wraps: glacier -> nothing -> glacier.
run("next");
assert.strictEqual(stateFile(), "nothing", "next: glacier -> nothing");
run("next");
assert.strictEqual(stateFile(), "glacier", "next wraps: nothing -> glacier");

// a stale name in the state file resolves to the default without a crash.
fs.writeFileSync(path.join(state, "nothing", "rice"), "deleted-rice\n");
assert.strictEqual(run("current").out, "nothing", "stale name falls back to default");

fs.rmSync(root, { recursive: true, force: true });
console.log("rice: list/current/set/next, unknown refused, stale + no-session fallbacks");
