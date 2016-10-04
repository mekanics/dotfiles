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
plugins=(git git-flow svn osx ruby rails rake brew gem rvm heroku pod capistrano zsh-syntax-highlighting npm node bower heroku boot2docker docker docker-compose bundler)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"
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

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# python virtualenv
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh

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

# Shorthand version of "openx", use "ox" instead.
alias ox=openx

# My own additions:
if [ -f ~/.zshrc_local ]; then
	source ~/.zshrc_local
fi