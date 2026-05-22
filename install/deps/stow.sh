#!/usr/bin/env bash
# install/deps/stow.sh

dep_name()         { echo "stow"; }
dep_is_installed() { is_installed stow; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install stow ;;
    linux) apt_install stow ;;
  esac
}
