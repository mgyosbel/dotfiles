#!/usr/bin/env bash
# install/deps/fzf.sh

dep_name()         { echo "fzf"; }
dep_is_installed() {
  local help
  is_installed fzf || return 1
  help=$(fzf --help) || return 1
  [[ "$help" == *--read0* && "$help" == *--print0* ]]
}
dep_install() {
  case "$PLATFORM" in
    macos) brew_install fzf ;;
    linux) apt_install fzf ;;
  esac
  if ! dep_is_installed; then
    log_fail 'fzf must support --read0 and --print0 for tmux-sessionizer; update fzf or correct PATH.'
    return 1
  fi
}
