#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
mv .config/bash/bashrc    bashrc
mv .config/vim/vimrc      vimrc
mv .config/git/config     gitconfig
mv .config/tmux/tmux.conf tmux.conf
echo "solve.sh: scattered the dotfiles back to the root, dropping the XDG copies (surrender)"
