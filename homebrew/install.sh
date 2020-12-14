#!/bin/sh

# Homebrew

if test ! $(command -v brew); then
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash
fi
