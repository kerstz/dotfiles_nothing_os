#!/usr/bin/env bash
# rice switcher: list / current / set <name> / next.
# a rice is quickshell/<name>/shell.qml + optional hypr/rices/<name>.lua.
# active name lives in the state file; absent/empty => "nothing".
set -u

DEFAULT_RICE="nothing"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nothing"
STATE_FILE="$STATE_DIR/rice"

usage() {
    cat >&2 <<'EOF'
usage: rice.sh <command>
  list            names that carry a shell.qml
  current         the active rice name
  set <name>      switch to <name>
  next            cycle to the next rice
EOF
}

# sorted so "next" cycles in a stable order.
rices() {
    local d name
    for d in "$ROOT"/quickshell/*/; do
        name="$(basename "$d")"
        [[ -f "$d/shell.qml" ]] && printf '%s\n' "$name"
    done | sort
}

is_rice() {
    local want="$1" name
    while IFS= read -r name; do
        [[ "$name" == "$want" ]] && return 0
    done < <(rices)
    return 1
}

current() {
    local name=""
    [[ -f "$STATE_FILE" ]] && name="$(tr -d '[:space:]' < "$STATE_FILE")"
    if [[ -z "$name" ]] || ! is_rice "$name"; then
        name="$DEFAULT_RICE"
    fi
    printf '%s\n' "$name"
}

# the rice's GTK theme source. nothing and y2k break the theme/<name>
# convention, so map them; everything else is theme/<name>.
gtk_src() {
    case "$1" in
        nothing) printf '%s\n' "$ROOT/theme/gtk" ;;
        y2k)     printf '%s\n' "$ROOT/theme/gtk-y2k" ;;
        *)       printf '%s\n' "$ROOT/theme/$1" ;;
    esac
}

# point GTK apps at the active rice's css. launched apps pick it up; already
# running ones keep their look until relaunched.
apply_gtk() {
    local src cfg; src="$(gtk_src "$1")"
    [[ -d "$src" ]] || return 0
    cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
    if [[ -f "$src/gtk-3.0/gtk.css" ]]; then
        mkdir -p "$cfg/gtk-3.0"; cp -f "$src/gtk-3.0/gtk.css" "$cfg/gtk-3.0/gtk.css"
    fi
    if [[ -f "$src/gtk-4.0/gtk.css" ]]; then
        mkdir -p "$cfg/gtk-4.0"; cp -f "$src/gtk-4.0/gtk.css" "$cfg/gtk-4.0/gtk.css"
    fi
}

# relaunch the shell for a rice. returns 0 if it is still alive after.
launch_shell() {
    local name="$1" n=0
    pkill -x quickshell 2>/dev/null || true
    # wait for the old shell to release its socket, not a blind sleep.
    while pgrep -x quickshell >/dev/null 2>&1 && (( n < 20 )); do
        sleep 0.1; n=$(( n + 1 ))
    done
    setsid qs -p "$ROOT/quickshell/$name" >/dev/null 2>&1 &
    # a broken shell.qml exits at once; give it a beat, then check it survived.
    sleep 0.6
    pgrep -x quickshell >/dev/null 2>&1
}

apply() {
    local name="$1" prev
    prev="$(current)"
    # write first: the state file is the source of truth and must land even
    # when nothing below can run.
    mkdir -p "$STATE_DIR"
    printf '%s\n' "$name" > "$STATE_FILE"
    apply_gtk "$name"

    local live=0
    if command -v qs >/dev/null 2>&1 \
        && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
        if launch_shell "$name"; then
            live=1
        else
            # the new shell died: roll back so the session is never left bare.
            printf '%s\n' "$prev" > "$STATE_FILE"
            apply_gtk "$prev"
            launch_shell "$prev" || true
            command -v hyprctl >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1 || true
            printf 'rice: %s failed to start, rolled back to %s\n' "$name" "$prev" >&2
            exit 1
        fi
    fi

    if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        hyprctl reload >/dev/null 2>&1 || true
        live=1
    fi

    if (( live )); then
        printf 'rice -> %s (applied)\n' "$name"
    else
        printf 'rice -> %s (saved; applies on next login)\n' "$name"
    fi
}

cmd="${1:-current}"
case "$cmd" in
    list)
        rices
        ;;
    current)
        current
        ;;
    set)
        name="${2:-}"
        if [[ -z "$name" ]]; then
            echo "rice.sh: set needs a name" >&2
            echo "available:" >&2
            rices | sed 's/^/  /' >&2
            exit 2
        fi
        if ! is_rice "$name"; then
            echo "rice.sh: unknown rice '$name'" >&2
            echo "available:" >&2
            rices | sed 's/^/  /' >&2
            exit 1
        fi
        apply "$name"
        ;;
    next)
        mapfile -t all < <(rices)
        if (( ${#all[@]} == 0 )); then
            echo "rice.sh: no rices found under $ROOT/quickshell" >&2
            exit 1
        fi
        cur="$(current)"
        target="${all[0]}"
        for i in "${!all[@]}"; do
            if [[ "${all[$i]}" == "$cur" ]]; then
                target="${all[$(( (i + 1) % ${#all[@]} ))]}"
                break
            fi
        done
        apply "$target"
        ;;
    -h | --help | help)
        usage
        ;;
    *)
        echo "rice.sh: unknown command '$cmd'" >&2
        usage
        exit 2
        ;;
esac
