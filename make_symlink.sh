#!/bin/bash

# Install dotfiles
# Shamelessly copied from github.com/swissmanu/, which is shamelessly copied from github.com/pstadler/
for symlink in gitconfig gitignore_global slate zshrc
do
	rm ~/.$symlink
	ln -s $PWD/$symlink ~/.$symlink
done

# Link Sublime
# done with cask
# ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
rm ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings
ln -s $PWD/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings