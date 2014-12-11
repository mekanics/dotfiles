#!/bin/bash

# install xcode first
echo "Install Xcode first: https://itunes.apple.com/ch/app/xcode/id497799835?l=en&mt=12"
read nothing
echo "Open and accept the terms"
xcode-select --install

# install homebrew
echo "installing homebrew"
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# brewfile
echo "brewfile"
brew bundle Brewfile

# oh-my-zsh
echo "installing oh-my-zsh"
wget --no-check-certificate http://install.ohmyz.sh -O - | sh
source ~/.zshrc

cd ~/.oh-my-zsh/custom/plugins
git clone git://github.com/zsh-users/zsh-syntax-highlighting.git

cd -1

# ruby
echo "updating ruby"
rbenv install 2.1.4
rbenv rehash

# install dotfiles
echo "Install dotfiles"
./make_symlink.sh
source ~/.zshrc

# Try out a ruby.
rbenv shell 2.1.4
# Enable a newly installed ruby, persistently, globally.
rbenv global 2.1.4
rbenv rehash

gem install bundler
rbenv rehash
bundle install --path vendor

# cocoapods
echo "installing cocoapods"
gem install cocoapods

#
gem install git-up

# Caskfile
echo "execute the Caskfile"
brew bundle Caskfile

# config osx
./config_osx.sh
