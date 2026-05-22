#!/usr/bin/env bash
# install/lib/common.sh
# Shared utilities sourced by registry.sh and all dep modules.

# ─────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────
log_install() { echo -e "${GREEN}[INSTALL]${NC}  $*"; }
log_skip()    { echo -e "${CYAN}[SKIP]${NC}     $*"; }
log_fail()    { echo -e "${RED}[FAIL]${NC}     $*"; }
log_info()    { echo -e "${YELLOW}[INFO]${NC}     $*"; }
log_dry()     { echo -e "${BOLD}[DRY-RUN]${NC}  $*"; }

# ─────────────────────────────────────────────
# Platform detection
# ─────────────────────────────────────────────
_detect_platform() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)
      echo -e "${RED}Unsupported OS: $(uname -s)${NC}" >&2
      exit 1
      ;;
  esac
}

PLATFORM="${PLATFORM:-$(_detect_platform)}"

# ─────────────────────────────────────────────
# Dry-run flag (set by orchestrator, read here)
# ─────────────────────────────────────────────
DRY_RUN="${DRY_RUN:-0}"

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────
is_installed() {
  command -v "$1" &>/dev/null
}

# Run apt-get update at most once per session.
# Uses a sentinel file in /tmp.
apt_update_once() {
  local sentinel="/tmp/.dotfiles_apt_updated"
  if [[ ! -f "$sentinel" ]]; then
    log_info "Running apt-get update..."
    sudo apt-get update -qq
    touch "$sentinel"
  fi
}

brew_install() {
  local pkg="$1"
  brew install "$pkg"
}

apt_install() {
  local pkg="$1"
  apt_update_once
  sudo apt-get install -y "$pkg"
}

# Idempotent git clone: only clones if destination does not exist.
git_clone_if_missing() {
  local repo_url="$1"
  local dest="$2"
  if [[ -d "$dest" ]]; then
    return 0
  fi
  git clone "$repo_url" "$dest"
}

# Run a curl-piped install script.
curl_install() {
  local url="$1"
  shift
  curl -fsSL "$url" | bash -s -- "$@"
}
