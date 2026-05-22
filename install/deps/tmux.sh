#!/usr/bin/env bash
# install/deps/tmux.sh

dep_name()         { echo "tmux"; }
dep_is_installed() { is_installed tmux; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install tmux ;;
    linux) apt_install tmux ;;
  esac
}
