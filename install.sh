#!/bin/bash

# Install dotfiles
# Shamelessly copied from github.com/pstadler/
for symlink in gitconfig gitignore_global slate zshrc
do
	rm ~/.$symlink
	ln -s $PWD/$symlink ~/.$symlink
done

# Link Sublime
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl