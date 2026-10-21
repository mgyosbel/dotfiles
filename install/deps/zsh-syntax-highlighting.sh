#!/usr/bin/env bash
# install/deps/zsh-syntax-highlighting.sh

dep_name()         { echo "zsh-syntax-highlighting"; }
dep_requires() { printf '%s\n' git oh-my-zsh; }
dep_is_installed() {
  local dest="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-syntax-highlighting"
  [[ -r "$dest/zsh-syntax-highlighting.plugin.zsh" && -r "$dest/zsh-syntax-highlighting.zsh" ]]
}
dep_install() {
  local dest="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-syntax-highlighting"
  git_clone_if_missing \
    https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$dest"
}
