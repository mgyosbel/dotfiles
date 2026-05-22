#!/usr/bin/env bash
# install/deps/kubectl.sh

dep_name()         { echo "kubectl"; }
dep_is_installed() { is_installed kubectl; }
dep_install() {
  case "$PLATFORM" in
    macos)
      brew_install kubectl
      ;;
    linux)
      local version
      version="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
      curl -fsSL "https://dl.k8s.io/release/${version}/bin/linux/amd64/kubectl" -o /tmp/kubectl
      install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
      rm /tmp/kubectl
      ;;
  esac
}
