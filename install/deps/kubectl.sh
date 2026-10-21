#!/usr/bin/env bash
dep_name() { echo kubectl; }
dep_requires() { if [[ "$PLATFORM" == linux ]]; then echo curl; fi; }
dep_is_installed() { is_installed kubectl || [[ -x /usr/local/bin/kubectl ]]; }
dep_install() (
  set -euo pipefail
  if [[ "$PLATFORM" == macos ]]; then brew_install kubectl; exit; fi
  # Subshell-scoped variables remain available to EXIT traps on Bash 3.2.
  version="${KUBECTL_VERSION:-}"
  case "$ARCH" in amd64|arm64) ;; *) log_fail "Unsupported kubectl architecture: $ARCH"; exit 1 ;; esac
  [[ -n "$version" ]] || version=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
  [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { log_fail 'KUBECTL_VERSION must be a stable vx.y.z version'; exit 1; }
  command -v sha256sum >/dev/null || { log_fail 'sha256sum is required'; exit 1; }
  work=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-kubectl.XXXXXXXX")
  trap 'rm -rf -- "$work"' EXIT
  url="https://dl.k8s.io/release/$version/bin/linux/$ARCH/kubectl"
  curl -fsSL "$url" -o "$work/kubectl"
  expected=$(curl -fsSL "$url.sha256")
  [[ "$expected" =~ ^[a-fA-F0-9]{64}$ ]] || { log_fail 'Invalid kubectl checksum response'; exit 1; }
  actual=$(sha256sum "$work/kubectl"); actual=${actual%% *}
  [[ "$actual" == "$expected" ]] || { log_fail 'kubectl checksum mismatch'; exit 1; }
  as_root install -d /usr/local/bin
  as_root install -o root -g root -m 0755 "$work/kubectl" /usr/local/bin/kubectl
)
