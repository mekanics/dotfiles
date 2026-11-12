# dotfiles

## HowTo

To install the whole thing, run this

```bash
git clone https://github.com/mekanics/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

## Tests

```bash
zsh zsh/test/shell_env_test.zsh       # login shell: PATH, prompt, plugins, aliases
lua hammerspoon/test/airpods_test.lua # Hammerspoon AirPods toggle
```

The shell test starts a fresh `zsh -ilc` from the checkout it lives in, so it
also works from a worktree. It reads the real `~/.oh-my-zsh` and `~/.zshrc_local`.

## What's included

-   [x] Git config
-   [x] AppStore App
-   [x] Homebrew
-   [x] tmux settings
-   [x] vim settings
-   [ ] gpg
-   [ ] auto mount smb
-   [x] auto delete old downloads
