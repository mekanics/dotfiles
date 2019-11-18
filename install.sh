#!/bin/bash

RUBY_VERSION='2.5.3'

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
brew bundle

# setup the dock
echo "Setup the dock"
./dock_apps.sh

# Setup tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# oh-my-zsh
echo "installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
source ~/.zshrc

cd ~/.oh-my-zsh/custom/plugins
git clone git://github.com/zsh-users/zsh-syntax-highlighting.git
cd -1

# install dotfiles
echo "Install dotfiles"
./make_symlink.sh

echo "export DEFAULT_USER='alexandrejoly'" >> ~/.zshrc_local

# install auto suggestions
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

source ~/.zshrc

# Setup Ruby
echo "updating ruby"
rbenv install $RUBY_VERSION
rbenv shell $RUBY_VERSION
rbenv global $RUBY_VERSION
rbenv rehash
ruby -v

source ~/.zshrc

gem install bundler
rbenv rehash
bundle install --path vendor

# cocoapods
echo "installing cocoapods"
gem install cocoapods

# fastlane
echo "installing fastlane"
gem install fastlane

# Setup Python
pip install virtualenv

# Setup NVM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
nvm install node
nvm alias default node



# config osx
./config_osx.sh

