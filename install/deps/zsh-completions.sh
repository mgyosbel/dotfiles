#!/usr/bin/env bash
# install/deps/zsh-completions.sh

dep_name()         { echo "zsh-completions"; }
dep_is_installed() {
  local dest="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-completions"
  [[ -d "$dest" ]]
}
dep_requires()     { echo "oh-my-zsh"; }
dep_install() {
  local dest="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-completions"
  git_clone_if_missing \
    https://github.com/zsh-users/zsh-completions.git \
    "$dest"
}
