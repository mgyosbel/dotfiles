#!/usr/bin/env bash
# install/deps/go.sh

dep_name()         { echo "go"; }
dep_is_installed() { is_installed go || [[ -x "/usr/local/go/bin/go" ]]; }
dep_install() {
  case "$PLATFORM" in
    macos)
      brew_install go
      ;;
    linux)
      local GO_VERSION="1.22.3"
      local GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz"
      local TMP_FILE="/tmp/${GO_TARBALL}"
      curl -fsSL "https://go.dev/dl/${GO_TARBALL}" -o "$TMP_FILE"
      rm -rf /usr/local/go
      tar -C /usr/local -xzf "$TMP_FILE"
      rm "$TMP_FILE"
      log_info "Go installed to /usr/local/go — ensure /usr/local/go/bin is in your PATH."
      ;;
  esac
}
