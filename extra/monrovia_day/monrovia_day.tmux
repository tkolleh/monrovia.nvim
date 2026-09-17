#!/usr/bin/env bash
# Monrovia colors for Tmux
# Style: monrovia_day
# Upstream: https://github.com/tkolleh/monrovia.nvim/raw/main/extra/monrovia_day/monrovia_day.tmux
set -g mode-style "fg=#e4dcd4,bg=#643f61"
set -g message-style "fg=#e4dcd4,bg=#643f61"
set -g message-command-style "fg=#e4dcd4,bg=#643f61"
set -g pane-border-style "fg=#643f61"
set -g pane-active-border-style "fg=#2848a9"
set -g status "on"
set -g status-justify "left"
set -g status-style "fg=#643f61,bg=#e4dcd4"
set -g status-left-length "100"
set -g status-right-length "100"
set -g status-left-style NONE
set -g status-right-style NONE
set -g status-left "#[fg=#e4dcd4,bg=#2848a9,bold] #S #[fg=#2848a9,bg=#e4dcd4,nobold,nounderscore,noitalics]"
set -g status-right "#[fg=#e4dcd4,bg=#e4dcd4,nobold,nounderscore,noitalics]#[fg=#2848a9,bg=#e4dcd4] #{prefix_highlight} #[fg=#643f61,bg=#e4dcd4,nobold,nounderscore,noitalics]#[fg=#e4dcd4,bg=#643f61] %Y-%m-%d  %I:%M %p #[fg=#2848a9,bg=#643f61,nobold,nounderscore,noitalics]#[fg=#e4dcd4,bg=#2848a9,bold] #h "
setw -g window-status-activity-style "underscore,fg=#42272f,bg=#e4dcd4"
setw -g window-status-separator ""
setw -g window-status-style "NONE,fg=#42272f,bg=#e4dcd4"
setw -g window-status-format "#[fg=#e4dcd4,bg=#e4dcd4,nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#e4dcd4,bg=#e4dcd4,nobold,nounderscore,noitalics]"
setw -g window-status-current-format "#[fg=#e4dcd4,bg=#643f61,nobold,nounderscore,noitalics]#[fg=#e4dcd4,bg=#643f61,bold] #I  #W #F #[fg=#643f61,bg=#e4dcd4,nobold,nounderscore,noitalics]"
