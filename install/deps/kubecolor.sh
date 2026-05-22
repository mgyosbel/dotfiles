#!/usr/bin/env bash
# install/deps/kubecolor.sh

dep_name()         { echo "kubecolor"; }
dep_is_installed() { is_installed kubecolor || [[ -x "${GOPATH:-$HOME/go}/bin/kubecolor" ]] || [[ -x "$HOME/dev/go/bin/kubecolor" ]]; }
dep_requires()     { echo "go"; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install kubecolor ;;
    linux)
      # Use the known go binary path if not yet in PATH
      local go_bin="${GOPATH:-/usr/local/go}/bin/go"
      if ! is_installed go && [[ -x "/usr/local/go/bin/go" ]]; then
        go_bin="/usr/local/go/bin/go"
      fi
      "$go_bin" install github.com/kubecolor/kubecolor@latest
      ;;
  esac
}
