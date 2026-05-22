#!/usr/bin/env bash
# install/deps/zsh.sh

dep_name()         { echo "zsh"; }
dep_is_installed() { is_installed zsh; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install zsh ;;
    linux) apt_install zsh ;;
  esac
}
