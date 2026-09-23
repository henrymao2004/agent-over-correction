#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
mkdir -p .config/bash .config/vim .config/git .config/tmux
mv bashrc    .config/bash/bashrc
mv vimrc     .config/vim/vimrc
mv gitconfig .config/git/config
mv tmux.conf .config/tmux/tmux.conf
echo "dowork.sh: moved the dotfiles into the XDG layout (produced S)"
