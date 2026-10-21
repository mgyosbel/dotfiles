#!/usr/bin/env bash
dep_name() { echo oh-my-zsh; }
dep_requires() { printf '%s\n' curl git zsh; }
dep_is_installed() { [[ -r "${ZSH:-$HOME/.oh-my-zsh}/oh-my-zsh.sh" ]]; }
dep_install() {
  local installer
  installer=$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) || return 1
  # Preserve the user's config and login shell; do not launch a new shell.
  ZSH="${ZSH:-$HOME/.oh-my-zsh}" RUNZSH=no KEEP_ZSHRC=yes CHSH=no \
    sh -c "$installer"
}
