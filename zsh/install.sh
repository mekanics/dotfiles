#!/bin/sh

# oh-my-zsh will be installed directly by 'script/install'

# Add my theme
DOT=$HOME/.dotfiles
ln -s $DOT/zsh/themes/alex.zsh-theme ~/.oh-my-zsh/custom/themes/alex.zsh-theme

# zsh syntax higlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# install auto suggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

source ~/.zshrc
