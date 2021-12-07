#!/bin/bash

## NVS
export NVS_HOME="$HOME/.nvs"
git clone https://github.com/jasongin/nvs "$NVS_HOME"
. "$NVS_HOME/nvs.sh" install

nvs add lts
nvs link lts

## YARN
brew install yarn
brew uninstall node --ignore-dependencies

## Link NODE
mkdir $HOMEBREW_CELLAR/node
ln -s $NVS_HOME/default/ $HOMEBREW_CELLAR/node

brew link --overwrite node
brew pin node
