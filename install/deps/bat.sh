#!/usr/bin/env bash
# install/deps/bat.sh
#
# On Debian/Ubuntu the binary is 'batcat'; the .zshrc alias handles the rename.

dep_name()         { echo "bat"; }
dep_is_installed() { is_installed bat || is_installed batcat; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install bat ;;
    linux) apt_install bat ;;
  esac
}
