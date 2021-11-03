#!/bin/zsh

# Homebrew

if test ! $(command -v brew); then
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
