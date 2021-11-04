#!/bin/zsh

# oh-my-zsh will be installed directly by 'script/install'

# Add my theme
DOT=$HOME/.dotfiles
ln -s $DOT/zsh/themes/alex.zsh-theme ~/.oh-my-zsh/custom/themes/alex.zsh-theme

# zsh syntax higlighting
dst=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
if [ ! -d "$dst" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $dst
fi

# install auto suggestions
dst=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
if [ ! -d "$dst" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $dst
fi
