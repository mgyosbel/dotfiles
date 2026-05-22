#!/usr/bin/env bash
# install/deps/zsh-syntax-highlighting.sh

dep_name()         { echo "zsh-syntax-highlighting"; }
dep_is_installed() { [[ -d "$HOME/zsh-syntax-highlighting" ]]; }
dep_install() {
  git_clone_if_missing \
    https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$HOME/zsh-syntax-highlighting"
}
