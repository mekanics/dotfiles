#!/bin/sh

# Homebrew

if test $(which brew); then
    echo "Homebrew already installed -> exit"
    exit 0
fi

curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash
