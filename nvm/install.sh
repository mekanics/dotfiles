#!/bin/bash

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.0/install.sh | bash
nvm install node
nvm alias default node
