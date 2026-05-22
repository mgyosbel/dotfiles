#!/usr/bin/env bash
# install/deps/git.sh

dep_name()         { echo "git"; }
dep_is_installed() { is_installed git; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install git ;;
    linux) apt_install git ;;
  esac
}
