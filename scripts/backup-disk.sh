#!/usr/bin/env bash
# Back up files to another disk, for Settings > System > Disk backup.
#
#   backup-disk.sh profiles                       JSON: the profiles and
#                                                 whether each has anything
#   backup-disk.sh plan    <profile> <dest> [paths...]   dry run: count+size
#   backup-disk.sh run      <profile> <dest> [keep] [paths...]   do it
#   backup-disk.sh snapshots <profile> <dest>     JSON: existing snapshots
#
# rsync only, no sudo, no root. Each run is a dated snapshot under
# <dest>/Nothing-Backups/<profile>/; unchanged files are hard-linked to the
# previous snapshot (--link-dest), so ten snapshots of a 50 GB home cost
# ~50 GB plus what changed, not 500. `keep` prunes to the newest N (0 = all).
#
# Profiles choose WHAT, never WHERE (the destination is always the disk you
# pick). Caches, trashes and the usual throwaway trees are left out of the
# "session" profile so a home backup is your files, not gigabytes of
# browser cache. Secrets (.ssh, .gnupg) are kept in "session" and "config"
# because a backup that drops your keys is a surprise; a destination you do
# not control is your call to make.
set -uo pipefail

HOME_DIR="${HOME:?}"

# ── Profiles ──────────────────────────────────────────────────────────
# sources() prints the paths a profile covers, one per line, that exist.
sources() {
    case "$1" in
        session)   printf '%s\n' "$HOME_DIR" ;;
        config)    printf '%s\n' \
                       "$HOME_DIR/.config" "$HOME_DIR/.local/share" \
                       "$HOME_DIR/.local/bin" "$HOME_DIR/.mozilla" \
                       "$HOME_DIR/.gnupg" "$HOME_DIR/.ssh" \
                       "$HOME_DIR/.bashrc" "$HOME_DIR/.zshrc" \
                       "$HOME_DIR/.profile" "$HOME_DIR/.gitconfig" ;;
        documents) printf '%s\n' \
                       "$HOME_DIR/Documents" "$HOME_DIR/Desktop" \
                       "$HOME_DIR/Pictures" "$HOME_DIR/Music" \
                       "$HOME_DIR/Videos" "$HOME_DIR/Images" "$HOME_DIR/Vidéos" ;;
        custom)    shift; printf '%s\n' "$@" ;;
        *)         return 1 ;;
    esac
}

exists_sources() {
    local p
    while IFS= read -r p; do
        [ -e "$p" ] && printf '%s\n' "$p"
    done
}

# Throwaway trees, never worth copying. Patterns are rsync --exclude, matched
# against the path below each source root.
EXCLUDES=(
    ".cache" "*/.cache" ".cache/**"
    ".local/share/Trash" "*/Trash" ".local/share/Steam" ".steam"
    ".var/app/*/cache" ".var/app/*/.cache"
    "*/node_modules" "*/.venv" "*/__pycache__" "*/target/debug" "*/target/release"
    ".cargo/registry" ".rustup/toolchains" ".npm/_cacache" ".gradle/caches"
    ".local/share/baloo" ".local/share/tracker" ".local/share/gvfs-metadata"
    "*.pyc" "*/Cache" "*/CachedData" "*/Code Cache" "*/GPUCache" "*/ShaderCache"
    ".mozilla/firefox/*/cache2" ".mozilla/firefox/*/storage/default/*/cache"
    ".local/share/libvirt/images" "*.qcow2" "*.vmdk"
    "lost+found" ".thumbnails" "*/.thumbnails"
)

# Fills the named array with --exclude pairs. An array, not a string: a
# pattern with a space ("*/Code Cache") or a glob must reach rsync whole.
build_excludes() {
    local -n _out="$1"; local e
    _out=()
    for e in "${EXCLUDES[@]}"; do _out+=(--exclude "$e"); done
}

# ── Destination ───────────────────────────────────────────────────────
# A snapshot must never land inside one of its own sources, or it copies
# itself forever. Refused up front, with the reason.
dest_root() { printf '%s/Nothing-Backups/%s' "$1" "$2"; }

check_dest() {
    local profile="$1" dest="$2"; shift 2
    [ -n "$dest" ] || { echo "no destination chosen" >&2; return 2; }
    local real; real="$(cd "$dest" 2>/dev/null && pwd -P)" \
        || { echo "the destination does not exist: $dest" >&2; return 2; }
    [ -w "$real" ] || { echo "the destination is not writable: $real" >&2; return 2; }
    local root; root="$(dest_root "$real" "$profile")"
    local src srcreal
    while IFS= read -r src; do
        srcreal="$(cd "$src" 2>/dev/null && pwd -P)" || continue
        case "$root/" in
            "$srcreal"/*) echo "the destination is inside $src — pick a folder on the backup disk instead" >&2; return 2 ;;
        esac
        case "$srcreal/" in
            "$real"/*) echo "the destination contains $src — pick a folder that is not a parent of what you back up" >&2; return 2 ;;
        esac
    done < <(sources "$profile" "$@" | exists_sources)
    printf '%s\n' "$real"
}

# ── Commands ──────────────────────────────────────────────────────────
cmd_profiles() {
    # JSON: [{ key, has, count }]. count is cheap (names only, one level).
    printf '['
    local first=1 key
    for key in session config documents; do
        local n; n="$(sources "$key" | exists_sources | wc -l)"
        [ "$first" = 1 ] || printf ','
        first=0
        printf '{"key":"%s","has":%s,"count":%s}' "$key" \
            "$([ "$n" -gt 0 ] && echo true || echo false)" "$n"
    done
    printf ']\n'
}

cmd_plan() {
    local profile="$1" dest="$2"; shift 2
    local real; real="$(check_dest "$profile" "$dest" "$@")" || return $?
    mapfile -t srcs < <(sources "$profile" "$@" | exists_sources)
    [ "${#srcs[@]}" -gt 0 ] || { echo "nothing to back up for this profile" >&2; return 3; }
    # --dry-run --stats: what a real run would copy now.
    local out
    local excl; build_excludes excl
    # --link-dest against the latest snapshot, so the estimate is the delta
    # the real run would copy, not the whole source again.
    local root; root="$(dest_root "$real" "$profile")"
    local linkarg=(); [ -d "$root/latest" ] && linkarg=("--link-dest=$root/latest")
    out="$(rsync -aAX --dry-run --stats "${linkarg[@]}" "${excl[@]}" \
        "${srcs[@]}" "$root/.plan-probe" 2>/dev/null)" || true
    local files size
    files="$(printf '%s' "$out" | sed -n 's/^Number of regular files transferred: //p' | tr -d ',')"
    size="$(printf '%s' "$out" | sed -n 's/^Total transferred file size: \([0-9,]*\).*/\1/p' | tr -d ',')"
    printf '{"files":%s,"bytes":%s}\n' "${files:-0}" "${size:-0}"
}

cmd_snapshots() {
    local profile="$1" dest="$2"
    # realpath, to match where cmd_run/cmd_plan write (a symlinked or
    # trailing-slash destination would otherwise list nothing).
    local real; real="$(cd "$dest" 2>/dev/null && pwd -P)" || { printf '[]\n'; return 0; }
    local root; root="$(dest_root "$real" "$profile")"
    [ -d "$root" ] || { printf '[]\n'; return 0; }
    printf '['
    local first=1 d name
    while IFS= read -r d; do
        name="$(basename "$d")"
        case "$name" in 20[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]*) ;; *) continue ;; esac
        # Size written at creation (one walk then, not on every listing).
        local bytes
        if [ -f "$d/.nothing-size" ]; then
            bytes="$(cat "$d/.nothing-size")"
        else
            bytes="$(du -sb "$d" 2>/dev/null | cut -f1)"
        fi
        [ "$first" = 1 ] || printf ','
        first=0
        printf '{"name":"%s","bytes":%s}' "$name" "${bytes:-0}"
    done < <(find "$root" -maxdepth 1 -mindepth 1 -type d | sort -r)
    printf ']\n'
}

cmd_run() {
    local profile="$1" dest="$2"; shift 2
    local keep=0
    if [ "${1:-}" ] && printf '%s' "${1:-}" | grep -qE '^[0-9]+$'; then keep="$1"; shift; fi
    local real; real="$(check_dest "$profile" "$dest" "$@")" || return $?
    mapfile -t srcs < <(sources "$profile" "$@" | exists_sources)
    [ "${#srcs[@]}" -gt 0 ] || { echo "nothing to back up for this profile" >&2; return 3; }

    local root; root="$(dest_root "$real" "$profile")"
    mkdir -p "$root" || { echo "cannot create $root" >&2; return 2; }
    local stamp; stamp="$(date +%Y%m%d-%H%M%S)"
    local target="$root/$stamp" link=""
    [ -d "$root/latest" ] && link="--link-dest=$root/latest"
    mkdir -p "$target"

    echo "START $stamp"
    # --info=progress2 gives one overall percentage; -aAX keeps perms, ACLs,
    # xattrs. Partial-transfer exits (23/24: a file vanished mid-copy) are not
    # failures of the backup as a whole.
    local excl; build_excludes excl
    local linkarg=(); [ -n "$link" ] && linkarg=("$link")
    rsync -aAX --delete --info=progress2 --no-inc-recursive \
        "${linkarg[@]}" "${excl[@]}" \
        "${srcs[@]}" "$target/"
    local rc=$?
    if [ "$rc" -ne 0 ] && [ "$rc" -ne 23 ] && [ "$rc" -ne 24 ]; then
        echo "FAILED rsync exit $rc" >&2
        rm -rf -- "$target" 2>/dev/null || true
        return "$rc"
    fi
    ln -sfn "$stamp" "$root/latest"
    # Record the snapshot's apparent size once, so listing it later is a
    # file read, not a walk of a possibly huge tree.
    du -sb "$target" 2>/dev/null | cut -f1 > "$target/.nothing-size" || true

    # Prune: keep the newest N dated snapshots, drop the rest. Hard links mean
    # removing one only frees what was unique to it.
    if [ "$keep" -gt 0 ]; then
        local old
        while IFS= read -r old; do
            rm -rf -- "$old"
            echo "PRUNED $(basename "$old")"
        done < <(find "$root" -maxdepth 1 -mindepth 1 -type d \
                    -name '20*' | sort -r | tail -n +"$((keep + 1))")
    fi
    printf 'DONE %s\r\n' "$stamp"
}

case "${1:-}" in
    profiles)  cmd_profiles ;;
    plan)      shift; cmd_plan "$@" ;;
    run)       shift; cmd_run "$@" ;;
    snapshots) shift; cmd_snapshots "$@" ;;
    *)         echo "usage: backup-disk.sh profiles|plan|run|snapshots ..." >&2; exit 2 ;;
esac
