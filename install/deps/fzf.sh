#!/usr/bin/env bash
# install/deps/fzf.sh

dep_name()         { echo "fzf"; }
dep_is_installed() { is_installed fzf; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install fzf ;;
    linux) apt_install fzf ;;
  esac
}
