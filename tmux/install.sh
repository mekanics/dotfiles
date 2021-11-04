#!/bin/bash

brew install tmux

dst=~/.tmux/plugins/tpm
if [ ! -d "$dst" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

tmux source ~/.tmux.conf &&
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh
