#!/usr/bin/env bash
# install/deps/ghostty.sh
#
# Linux install is distro-specific and not automatable safely.
# Supported only on macOS via Homebrew Cask.

dep_name()      { echo "ghostty"; }
dep_platforms() { echo "macos"; }
dep_is_installed() { is_installed ghostty; }
dep_install() {
  brew install --cask ghostty
}
