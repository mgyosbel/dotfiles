#!/usr/bin/env bash
# install/deps/oh-my-zsh.sh
#
# RUNZSH=no   — do not switch to zsh after install
# KEEP_ZSHRC=yes — do not overwrite .zshrc (managed by stow)

dep_name()         { echo "oh-my-zsh"; }
dep_is_installed() { [[ -d "$HOME/.oh-my-zsh" ]]; }
dep_install() {
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
