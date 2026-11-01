set -g fish_color_normal 26262a
set -g fish_color_command 26262a
set -g fish_color_param 3a3a3c
set -g fish_color_quote 4f8a3d
set -g fish_color_redirection a2607f
set -g fish_color_end a2607f
set -g fish_color_error d9554c
set -g fish_color_comment 8b8376
set -g fish_color_autosuggestion a89f8f
set -g fish_color_operator 2f7fc8
set -g fish_color_escape 2f7fc8
set -g fish_color_valid_path 26262a
set -g fish_pager_color_prefix 2f7fc8
set -g fish_pager_color_completion 3a3a3c
set -g fish_pager_color_description 8b8376
set -g fish_pager_color_selected_background --background=bccde3

function fish_mode_prompt
end

function fish_right_prompt
end

function fish_prompt
    set -l here (prompt_pwd --dir-length=0)
    test "$here" = "~"; or set here (basename "$here")
    printf '[%s@%s %s]$ ' $USER (prompt_hostname) $here
end

function fish_title
    printf '%s@%s %s' $USER (prompt_hostname) (prompt_pwd)
end

function neofetch --description "Paper fetch"
    command fastfetch --config "$PAPER_DIR/apps/fastfetch/paper.jsonc" \
        --logo-type kitty-direct \
        --logo "$PAPER_DIR/assets/doodles/arch_plus.png" \
        --logo-width 27 --logo-height 14 --logo-padding-top 0 --logo-padding-left 0 --logo-padding-right 2 \
        $argv
end

function fish_greeting
    printf '[%s@%s ~]$ neofetch\n' $USER (prompt_hostname)
    neofetch
end
