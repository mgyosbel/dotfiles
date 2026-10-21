#!/usr/bin/env bash
# install/deps/ghostty.sh
#
# This module automates macOS installation via Homebrew Cask.
# Linux installation is documented as a separate distro-specific prerequisite.

dep_name()      { echo "ghostty"; }
dep_platforms() { echo "macos"; }
dep_is_installed() {
  is_installed ghostty ||
    [[ -x /Applications/Ghostty.app/Contents/MacOS/ghostty ]] ||
    [[ -x "$HOME/Applications/Ghostty.app/Contents/MacOS/ghostty" ]]
}
dep_install() {
  brew install --cask ghostty
}
