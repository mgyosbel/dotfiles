#!/usr/bin/env bash
dep_name() { echo starship; }
dep_requires() { echo curl; }
dep_is_installed() { is_installed starship || [[ -x "$HOME/.local/bin/starship" ]]; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install starship ;;
    linux)
      local installer
      installer=$(curl -fsSL https://starship.rs/install.sh) || return 1
      mkdir -p "$HOME/.local/bin" || return 1
      sh -c "$installer" -- --yes --bin-dir "$HOME/.local/bin"
      ;;
  esac
}
