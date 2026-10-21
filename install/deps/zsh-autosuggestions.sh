#!/usr/bin/env bash
dep_name() { echo zsh-autosuggestions; }
dep_requires() { printf '%s\n' git oh-my-zsh; }
dep_is_installed() {
  local dest="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-autosuggestions"
  [[ -r "$dest/zsh-autosuggestions.plugin.zsh" && -r "$dest/zsh-autosuggestions.zsh" ]]
}
dep_install() {
  local dest="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-autosuggestions"
  git_clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "$dest"
}
