#!/bin/bash
#
# Install Hammerspoon and take over ~/.hammerspoon.

if [ ! -d /Applications/Hammerspoon.app ]; then
    brew install --cask hammerspoon
fi

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
src="$DOTFILES_ROOT/hammerspoon/hammerspoon.symlink"
dst="$HOME/.hammerspoon"

if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "already linked $src to $dst"
else
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        backup="${dst}.backup"
        if [ -e "$backup" ]; then
            backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
        fi
        mv "$dst" "$backup"
        echo "moved $dst to $backup"
    fi
    ln -s "$src" "$dst"
    echo "linked $src to $dst"
fi

open -a Hammerspoon
