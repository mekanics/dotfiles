#!/bin/bash

## NVS
export NVS_HOME="$HOME/.nvs"
git clone https://github.com/jasongin/nvs "$NVS_HOME"
. "$NVS_HOME/nvs.sh" install

nvs add lts
nvs link lts

## Package managers: pnpm is primary; yarn only per-project via Corepack
pnpm add -g corepack
corepack enable --install-directory "${PNPM_HOME:-$HOME/Library/pnpm}/bin" yarn
corepack install -g yarn@1.22.22   # default for legacy projects without "packageManager"
