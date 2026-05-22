#!/usr/bin/env bash
# install/deps/curl.sh

dep_name()         { echo "curl"; }
dep_is_installed() { is_installed curl; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install curl ;;
    linux) apt_install curl ;;
  esac
}
