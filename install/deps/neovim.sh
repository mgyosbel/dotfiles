#!/usr/bin/env bash
# install/deps/neovim.sh

dep_name()         { echo "neovim"; }
dep_is_installed() {
  local output version
  is_installed nvim || return 1
  output=$(nvim --version) || return 1
  version=${output%%$'\n'*}; version=${version#NVIM v}
  version_at_least "$version" 0.11.2 && [[ "$output" == *LuaJIT* ]]
}
dep_install() {
  case "$PLATFORM" in
    macos) brew_install neovim ;;
    linux) apt_install neovim ;;
  esac
  if ! dep_is_installed; then
    log_fail 'Neovim >= 0.11.2 with LuaJIT is required by this LazyVim config. The package on PATH is incompatible; install a suitable release for your distro or correct PATH, then retry.'
    return 1
  fi
}
