#!/bin/bash

brew install tmux

export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/"

dst=~/.tmux/plugins/tpm
if [ ! -d "$dst" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

tmux start-server &&
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh
