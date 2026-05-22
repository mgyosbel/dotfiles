#!/usr/bin/env bash
# install/deps/kubecolor.sh

dep_name()         { echo "kubecolor"; }
dep_is_installed() { is_installed kubecolor; }
dep_requires()     { echo "go"; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install kubecolor ;;
    linux) go install github.com/kubecolor/kubecolor@latest ;;
  esac
}
