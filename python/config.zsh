export PYENV_ROOT="$HOME/.pyenv"

# zlib
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/zlib/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

# bzip2
export PATH="/usr/local/opt/bzip2/bin:$PATH"
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/bzip2/include"

# pyenv / virtualenv
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# PlatformeIO
export PATH="$PATH:$HOME/.platformio/penv/bin"
