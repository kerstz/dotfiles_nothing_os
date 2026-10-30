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

apply() {
    local name="$1"
    # write first: the state file is the source of truth and must land even
    # when nothing below can run.
    mkdir -p "$STATE_DIR"
    printf '%s\n' "$name" > "$STATE_FILE"

    local live=0
    # kill by name, not "pkill -f 'qs -p ...'" which would match our relaunch.
    if command -v qs >/dev/null 2>&1 \
        && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
        pkill -x quickshell 2>/dev/null || true
        sleep 0.3
        setsid qs -p "$ROOT/quickshell/$name" >/dev/null 2>&1 &
        live=1
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
