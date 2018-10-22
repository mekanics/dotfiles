#!/bin/bash

# Install dotfiles
# Shamelessly copied from github.com/swissmanu/, which is shamelessly copied from github.com/pstadler/
for symlink in gitconfig gitignore_global slate zshrc gemrc gitmessage
do
	rm ~/.$symlink
	ln -s $PWD/$symlink ~/.$symlink
done

rm ~/.oh-my-zsh/themes/alex.zsh-theme
ln -s $PWD/themes/alex.zsh-theme ~/.oh-my-zsh/themes/alex.zsh-theme