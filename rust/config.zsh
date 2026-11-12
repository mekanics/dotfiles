# rustup's ~/.cargo/env (sourced from ~/.zshenv) only adds cargo/bin when it is
# missing, so after path_helper it sits behind the system dirs. Move it to the
# front; typeset -U in .zshrc keeps this first occurrence.
[[ -d $HOME/.cargo/bin ]] && path=("$HOME/.cargo/bin" $path)
