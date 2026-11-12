#!/usr/bin/env zsh
# Observable environment of a fresh login shell built from THIS checkout's
# zsh/zprofile.symlink + zsh/zshrc.symlink — the same `zsh -ilc` that GUI apps
# and agents use to read the environment.
#
# Run: zsh zsh/test/shell_env_test.zsh
#
# Reads the real ~/.oh-my-zsh, ~/.zshenv and ~/.zshrc_local; writes only to a
# temp directory that is removed on exit.

emulate -L zsh
setopt no_unset pipe_fail

readonly repo=${0:A:h:h:h}
readonly shell_timeout=30
readonly probe_vars=(PATH DOT ZSH_THEME PROMPT LAST_PLUGIN EDITOR ZSH_TMUX_AUTOSTART)
typeset -i fails=0

tmp=$(mktemp -d "${TMPDIR:-/tmp}/shell_env_test.XXXXXX") || {
  print -u2 "cannot create temp dir"
  exit 2
}
cleanup() {
  [[ -n ${tmp-} && -d $tmp && ${tmp:t} == shell_env_test.* ]] && rm -rf -- "$tmp"
}
trap cleanup EXIT INT TERM

check() { # check <name> <detail-on-failure> <command...>
  local name=$1 detail=$2
  shift 2
  if "$@"; then
    print -r -- "ok   $name"
  else
    (( fails++ ))
    print -r -- "FAIL $name${detail:+: $detail}"
  fi
}

with_timeout() { # with_timeout <seconds> <command...>; exit 142 on timeout
  /usr/bin/perl -e 'alarm shift; exec @ARGV or die "exec: $!"' "$@"
}

# --- run the shell under test ---------------------------------------------------

[[ -e $HOME/.zshenv ]] && ln -s "$HOME/.zshenv" "$tmp/.zshenv"
[[ -e $repo/zsh/zprofile.symlink ]] && ln -s "$repo/zsh/zprofile.symlink" "$tmp/.zprofile"
ln -s "$repo/zsh/zshrc.symlink" "$tmp/.zshrc"
mkdir "$tmp/out"

probe='
plugins=(${plugins-})
LAST_PLUGIN=${plugins[-1]-}
for v in '"${probe_vars[*]}"'; do print -rn -- "${(P)v-}" > "$PROBE_OUT/$v"; done
'

shell_env=(HOME="$HOME" USER="$USER" TERM=xterm-256color SHELL=/bin/zsh
  ZDOTDIR="$tmp" PROBE_OUT="$tmp/out")
[[ -n ${SSH_AUTH_SOCK-} ]] && shell_env+=(SSH_AUTH_SOCK="$SSH_AUTH_SOCK")

with_timeout $shell_timeout env -i $shell_env /bin/zsh -ilc "$probe" \
  </dev/null >"$tmp/shell.log" 2>&1
shell_status=$?

typeset -A got
for v in $probe_vars; do
  got[$v]=''
  [[ -f $tmp/out/$v ]] && got[$v]=$(<"$tmp/out/$v")
done

check "login shell returns without a TTY (no tmux attach, no hang)" \
  "exit $shell_status, see output below" \
  test -f "$tmp/out/PATH"
(( shell_status == 0 )) || sed 's/^/     | /' "$tmp/shell.log" | head -20

entries=(${(s.:.)got[PATH]})

# --- PATH -------------------------------------------------------------------------

typeset -aU unique_entries=($entries)
dupes=(${(f)"$(print -rl -- $entries | sort | uniq -d)"})
check "PATH has no duplicate entries" "${(j:, :)dupes}" \
  test ${#entries} -eq ${#unique_entries}

missing=()
for d in $entries; do [[ -d $d ]] || missing+=$d; done
check "every PATH entry is an existing directory" "${(j:, :)missing}" \
  test ${#missing} -eq 0

helper_path=$(env -i /usr/libexec/path_helper -s)
helper_path=${${helper_path#PATH=\"}%%\"*}
lost=()
for d in ${(s.:.)helper_path}; do
  [[ -d $d && ${entries[(Ie)$d]} -eq 0 ]] && lost+=$d
done
check "keeps every existing macOS path_helper entry (/etc/paths, /etc/paths.d)" \
  "${(j:, :)lost}" test ${#lost} -eq 0

check "Homebrew bin precedes /usr/bin" "" \
  test ${entries[(Ie)/opt/homebrew/bin]} -gt 0 -a \
  ${entries[(Ie)/opt/homebrew/bin]} -lt ${entries[(Ie)/usr/bin]}

if [[ -r $HOME/.orbstack/shell/init.zsh ]]; then
  check "OrbStack bin is on PATH" "" test ${entries[(Ie)$HOME/.orbstack/bin]} -gt 0
fi

# --- dotfiles, prompt, plugins, editor ---------------------------------------------

check "DOT points at the checkout under test" "got '${got[DOT]}'" \
  test "${got[DOT]}" = "$repo"

check "no oh-my-zsh theme is loaded when starship is installed" \
  "ZSH_THEME='${got[ZSH_THEME]}'" test -z "${got[ZSH_THEME]}"

check "the prompt is rendered by starship" "" \
  test "${got[PROMPT]}" != "${got[PROMPT]/starship prompt/}"

check "zsh-syntax-highlighting is the last plugin" "last is '${got[LAST_PLUGIN]}'" \
  test "${got[LAST_PLUGIN]}" = zsh-syntax-highlighting

check "EDITOR waits for the file to close" "EDITOR='${got[EDITOR]}'" \
  test "${got[EDITOR]}" != "${got[EDITOR]/--wait/}"

check "tmux autostart is off without a TTY" \
  "ZSH_TMUX_AUTOSTART='${got[ZSH_TMUX_AUTOSTART]}'" \
  test "${got[ZSH_TMUX_AUTOSTART]}" = false

# --- aliases degrade gracefully ------------------------------------------------------

with_timeout 10 env -i HOME="$HOME" PATH=/usr/bin:/bin /bin/zsh -f -c \
  'source "$1" && eval "cat /etc/hosts" >/dev/null' zsh "$repo/system/aliases.zsh" \
  >/dev/null 2>&1
check "cat still works when bat is not installed" "" test $? -eq 0

print
if (( fails )); then
  print -r -- "$fails check(s) failed"
  exit 1
fi
print -r -- "all checks passed"
