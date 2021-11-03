#!/bin/zsh

cd "$(dirname "$0")/.."
pwd
DOTFILES_ROOT=$(pwd -P)
source script/helper

if test -f ~/.zshrc_local; then
    source ~/.zshrc_local
fi

if [ -z ${DEFAULT_USER+x} ]; then
    echo "export DEFAULT_USER='$(whoami)'" >>~/.zshrc_local
fi

setup_launchd() {
    local overwrite_all=false backup_all=false skip_all=false

    LAUNCH_PATH=~/Library/LaunchAgents
    for src in $(find -H $DOTFILES_ROOT/system/launchd -name '*.plist'); do

        dst="$LAUNCH_PATH/$(basename "${src}")"
        link_file "$src" "$dst"

        launchctl load "$dst"
    done

}
setup_launchd
