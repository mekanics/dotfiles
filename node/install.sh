#!/bin/bash

## NVS
export NVS_HOME="$HOME/.nvs"
git clone https://github.com/jasongin/nvs "$NVS_HOME"
. "$NVS_HOME/nvs.sh" install

nvs add lts
nvs link lts

## Package managers: pnpm is primary; yarn only per-project via Corepack
export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
PNPM_BIN="$PNPM_HOME/bin"

export PATH="$PNPM_BIN:$NVS_HOME/default/bin:$PATH"

# Bootstrap pnpm through npx rather than get.pnpm.io: its `pnpm setup` rewrites ~/.zshrc,
# replacing the dotfiles symlink with a copy.
if [ ! -x "$PNPM_BIN/pnpm" ]; then
  npx --yes pnpm@latest self-update \
    || { echo "node/install.sh: pnpm install failed" >&2; exit 1; }
fi

"$PNPM_BIN/pnpm" add -g corepack \
  || { echo "node/install.sh: corepack install failed" >&2; exit 1; }

# The yarn shim links into a versioned corepack folder: re-run this after `pnpm update -g`.
"$PNPM_BIN/corepack" enable --install-directory "$PNPM_BIN" yarn
# Default for legacy projects without a "packageManager" field (else Corepack picks Yarn 4).
"$PNPM_BIN/corepack" install -g yarn@1.22.22
