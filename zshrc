 # Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="lukerandall"
ZSH_THEME="alex"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias cat='bat'
alias ping='prettyping --nolegend'

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to disable command auto-correction.
# DISABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd.mm.yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git git-flow svn osx ruby rails rake brew gem rvm heroku pod capistrano zsh-syntax-highlighting npm nvm node bower heroku docker kubectl pip docker-compose bundler zsh-autosuggestions swiftpm)

source $ZSH/oh-my-zsh.sh

# User configuration

# Add the known ssh keys
ssh-add -A 2>/dev/null

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='subl --new-window'
else
  export EDITOR='subl --new-window'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  ssh-add
fi

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# GO
export GOPATH=~/go

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### FIX El Capitan rights
alias fixElCapitan="sudo chown -R $(whoami):admin /usr/local"

### open Xcode shortcut
openx() {
    fileToOpen='';
    find . -maxdepth 1 -name *.xcworkspace -print0 | while IFS= read -r -d '' file; do
        fileToOpen=$file
    done

    if [ -n "$fileToOpen" ]
    then
        echo "opening $fileToOpen"
        open $fileToOpen
    else
        find . -maxdepth 1 -name *.xcodeproj -print0 | while IFS= read -r -d '' file; do
            fileToOpen=$file
        done

        if [ -n "$fileToOpen" ]
        then
            echo "opening $fileToOpen"
            open $fileToOpen
        else
            echo "No xcode files to open."
        fi
    fi
}

# autosuggestion
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"

# Shorthand version of "openx", use "ox" instead.
alias ox=openx

# My own additions:
if [ -f ~/.zshrc_local ]; then
	source ~/.zshrc_local
fi

# GPG
export PATH="/usr/local/opt/gpg-agent/bin:$PATH"

# yarn
export PATH="$PATH:`yarn global bin`"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Fastlane
export PATH="$HOME/.fastlane/bin:$PATH"
[ -s "~/.fastlane/completions/completion.sh" ] && \. ~/.fastlane/completions/completion.sh

autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
