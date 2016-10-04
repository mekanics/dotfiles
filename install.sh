#!/bin/bash

$RUBY_VERSION='2.3.1'

# install xcode first
echo "Install Xcode first: https://itunes.apple.com/ch/app/xcode/id497799835?l=en&mt=12"
read nothing
echo "Open and accept the terms"
xcode-select --install

# install homebrew
echo "installing homebrew"
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# brewfile
echo "brewfile"
brew tap Homebrew/bundle
brew bundle Brewfile

# oh-my-zsh
echo "installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
source ~/.zshrc

cd ~/.oh-my-zsh/custom/plugins
git clone git://github.com/zsh-users/zsh-syntax-highlighting.git

cd -1

# ruby
echo "updating ruby"
rbenv install $RUBY_VERSION
rbenv rehash

# python

# install dotfiles
echo "Install dotfiles"
./make_symlink.sh

echo "export DEFAULT_USER='alexandrejoly'" >> ~/.zshrc_local

source ~/.zshrc

# Try out a ruby.
rbenv shell $RUBY_VERSION
# Enable a newly installed ruby, persistently, globally.
rbenv global $RUBY_VERSION
rbenv rehash

gem install bundler
rbenv rehash
bundle install --path vendor

# cocoapods
echo "installing cocoapods"
gem install cocoapods

# Caskfile
echo "execute the Caskfile"
brew bundle Caskfile

# config osx
./config_osx.sh
