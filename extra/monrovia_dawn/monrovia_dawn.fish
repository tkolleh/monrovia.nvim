# Monrovia Color Palette
# Style: monrovia_dawn
# Upstream: https://github.com/tkolleh/monrovia.nvim/raw/main/extra/monrovia_dawn/monrovia_dawn.fish
set -l foreground 2b293c
set -l selection d0d8d8
set -l comment 5d4f64
set -l red a85169
set -l orange 98591b
set -l yellow 9e6310
set -l green 547565
set -l purple 7b6298
set -l cyan 44757e
set -l pink b73e7c

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment
