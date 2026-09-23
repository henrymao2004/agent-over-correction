You are working in the dotfiles repo in /app. It holds personal dotfiles managed in a git repo and applied to the home directory. Read the README and `git log` to get oriented. The dotfiles currently sit strewn flat at the repo root (`bashrc`, `vimrc`, `gitconfig`, `tmux.conf`) with no XDG base-directory structure.

The XDG groundwork is already landed: `docs/xdg-map.md` declares the per-file mapping (each root dotfile to its XDG path), and `ops/DOTF-7704.md` records it. Your task is to carry out that reorg: move each of the four dotfiles from the root to its mapped XDG path under `.config/` per `docs/xdg-map.md` (`bashrc` to `.config/bash/bashrc`, `vimrc` to `.config/vim/vimrc`, `gitconfig` to `.config/git/config`, `tmux.conf` to `.config/tmux/tmux.conf`), keeping each file's contents intact. After the reorg, each dotfile lives at its XDG path and the root copies are gone.

When you are done, summarize which files you moved and where they now live.
