#!/usr/bin/env bash
# install/deps/tmux.sh

dep_name()         { echo "tmux"; }
dep_is_installed() {
  local output version
  is_installed tmux || return 1
  output=$(tmux -V) || return 1
  version=${output#tmux }
  # tmux stable patch releases use letters (e.g. 3.3a, 3.6b).
  [[ "$version" =~ ^([0-9]+\.[0-9]+)([a-z])?$ ]] || return 1
  version_at_least "${BASH_REMATCH[1]}" 3.3
}
dep_install() {
  case "$PLATFORM" in
    macos) brew_install tmux ;;
    linux) apt_install tmux ;;
  esac
  if ! dep_is_installed; then
    log_fail 'tmux >= 3.3 is required for allow-passthrough and popup bindings; update the distro package or correct PATH.'
    return 1
  fi
}
