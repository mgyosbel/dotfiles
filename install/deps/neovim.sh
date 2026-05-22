#!/usr/bin/env bash
# install/deps/neovim.sh

dep_name()         { echo "neovim"; }
dep_is_installed() { is_installed nvim; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install neovim ;;
    linux) apt_install neovim ;;
  esac
}
