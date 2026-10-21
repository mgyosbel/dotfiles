#!/usr/bin/env bash
dep_name() { echo go; }
dep_requires() { if [[ "$PLATFORM" == linux ]]; then echo curl; fi; }
dep_is_installed() { is_installed go || [[ -x /usr/local/go/bin/go ]]; }
dep_install() (
  set -euo pipefail
  if [[ "$PLATFORM" == macos ]]; then brew_install go; exit; fi
  # Subshell-scoped variables remain available to EXIT traps on Bash 3.2.
  version="${GO_VERSION:-1.27.2}" expected="${GO_SHA256:-}" stage="" had_old=0
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { log_fail 'GO_VERSION must be a stable x.y.z version'; exit 1; }
  case "$ARCH" in amd64|arm64) ;; *) log_fail "Unsupported Go architecture: $ARCH"; exit 1 ;; esac
  # https://go.dev/dl/?mode=json, checked 2026-10-18.
  if [[ -z "$expected" && "$version" == 1.27.2 ]]; then
    case "$ARCH" in
      amd64) expected=ecbadb99091a3f46e31f5f934b068b1864eafa7995211b39eaddf76996045fe5 ;;
      arm64) expected=94f3e30b8e374bc285e7dadc11e0865726b9bc6e85b841ccceaabc0214c6b7c8 ;;
    esac
  fi
  [[ "$expected" =~ ^[a-fA-F0-9]{64}$ ]] || { log_fail 'Set GO_SHA256 to the official checksum for the selected version/architecture'; exit 1; }
  command -v sha256sum >/dev/null || { log_fail 'sha256sum is required'; exit 1; }
  work=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-go.XXXXXXXX")
  trap 'rm -rf -- "$work"' EXIT
  archive="go${version}.linux-${ARCH}.tar.gz"
  curl -fsSL "https://go.dev/dl/$archive" -o "$work/$archive"
  actual=$(sha256sum "$work/$archive"); actual=${actual%% *}
  [[ "$actual" == "$expected" ]] || { log_fail 'Go archive checksum mismatch'; exit 1; }
  tar -xzf "$work/$archive" -C "$work"
  [[ -x "$work/go/bin/go" ]] || { log_fail 'Go archive is missing bin/go'; exit 1; }
  [[ "$(GOTOOLCHAIN=local "$work/go/bin/go" version)" == "go version go$version linux/$ARCH" ]] || {
    log_fail 'Staged Go executable does not match the selected release'; exit 1;
  }
  # Copy into a root-owned staging directory on the destination filesystem first.
  stage=$(as_root mktemp -d /usr/local/.dotfiles-go.XXXXXXXX)
  # Invoked by the EXIT trap.
  # shellcheck disable=SC2329
  cleanup_stage() {
    if [[ -n "$stage" ]]; then
      if [[ "$had_old" == 1 && ! -e /usr/local/go && ! -L /usr/local/go ]]; then
        if ! as_root mv -- "$stage/previous" /usr/local/go; then
          log_fail "Restore failed; previous Go retained at $stage/previous"
          return
        fi
      fi
      as_root rm -rf -- "$stage"
    fi
  }
  trap 'cleanup_stage; rm -rf -- "$work"' EXIT
  as_root cp -R -- "$work/go" "$stage/go"
  as_root chown -R root:root "$stage/go"
  if [[ -e /usr/local/go || -L /usr/local/go ]]; then
    as_root mv -- /usr/local/go "$stage/previous"
    had_old=1
  fi
  as_root mv -- "$stage/go" /usr/local/go
  log_info 'Go installed to /usr/local/go; add /usr/local/go/bin to PATH.'
)
