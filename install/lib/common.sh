#!/usr/bin/env bash
# Shared helpers; sourcing this file performs no installation or filesystem writes.
log_install() { printf '[INSTALL] %s\n' "$*"; }
log_skip()    { printf '[SKIP] %s\n' "$*"; }
log_fail()    { printf '[FAIL] %s\n' "$*" >&2; }
log_info()    { printf '[INFO] %s\n' "$*"; }
log_dry()     { printf '[DRY-RUN] %s\n' "$*"; }
DRY_RUN="${DRY_RUN:-0}"

detect_platform() {
  local os machine ID=""
  os=$(uname -s) || return 1
  case "$os" in
    Darwin) PLATFORM=macos; DISTRO=macos ;;
    Linux)
      [[ -r /etc/os-release ]] || { log_fail 'Cannot identify Linux distribution'; return 1; }
      # shellcheck disable=SC1091
      source /etc/os-release
      case "$ID" in
        debian|ubuntu) DISTRO=$ID ;;
        *) log_fail "Unsupported Linux distribution: $ID (expected Debian or Ubuntu)"; return 1 ;;
      esac
      PLATFORM=linux
      ;;
    *) log_fail "Unsupported OS: $os"; return 1 ;;
  esac
  machine=$(uname -m) || return 1
  case "$machine" in
    x86_64|amd64) ARCH=amd64 ;;
    arm64|aarch64) ARCH=arm64 ;;
    *) log_fail "Unsupported architecture: $machine"; return 1 ;;
  esac
  export PLATFORM DISTRO ARCH DRY_RUN
}

is_installed() { command -v "$1" >/dev/null 2>&1; }

# Compare numeric release components; callers strip tool-specific prefixes and
# suffixes. Reject prerelease/malformed input instead of treating it as stable.
version_at_least() {
  local actual=$1 minimum=$2 index a b
  local -a actual_parts minimum_parts
  [[ "$actual" =~ ^[0-9]+(\.[0-9]+)*$ && "$minimum" =~ ^[0-9]+(\.[0-9]+)*$ ]] || return 1
  IFS=. read -r -a actual_parts <<< "$actual"
  IFS=. read -r -a minimum_parts <<< "$minimum"
  for ((index=0; index<${#actual_parts[@]} || index<${#minimum_parts[@]}; index++)); do
    a=${actual_parts[index]:-0}; b=${minimum_parts[index]:-0}
    (( 10#$a >= 10#$b )) || return 1
    if (( 10#$a > 10#$b )); then return 0; fi
  done
}

as_root() {
  if [[ "$DRY_RUN" == 1 ]]; then
    log_dry "System command: $*"
  elif [[ "$EUID" -eq 0 ]]; then
    "$@"
  elif is_installed sudo; then
    sudo -- "$@"
  else
    log_fail "sudo is required for system installation: $1"
    return 1
  fi
}

apt_update_once() {
  if [[ "$DRY_RUN" == 1 ]]; then
    log_dry 'apt-get update'
    return 0
  fi
  [[ -n "${INSTALL_STATE_DIR:-}" && -d "$INSTALL_STATE_DIR" ]] || {
    log_fail 'apt helpers must run through install.sh (missing per-run state)'
    return 1
  }
  if [[ ! -f "$INSTALL_STATE_DIR/apt-updated" ]]; then
    as_root apt-get update -qq || return 1
    : > "$INSTALL_STATE_DIR/apt-updated"
  fi
}

apt_install() {
  apt_update_once || return 1
  as_root apt-get install -y "$@"
}

brew_install() {
  if [[ "$DRY_RUN" == 1 ]]; then log_dry "brew install $*"; else brew install "$@"; fi
}

git_clone_if_missing() {
  local repo_url="$1" dest="$2"
  [[ ! -d "$dest" ]] || return 0
  if [[ "$DRY_RUN" == 1 ]]; then
    log_dry "git clone $repo_url $dest"
  else
    git clone "$repo_url" "$dest"
  fi
}

curl_install() {
  local url="$1"
  shift
  if [[ "$DRY_RUN" == 1 ]]; then log_dry "Installer: $url"; else curl -fsSL "$url" | bash -s -- "$@"; fi
}

find_homebrew() {
  local candidate
  if is_installed brew; then command -v brew; return 0; fi
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [[ -x "$candidate" ]]; then printf '%s\n' "$candidate"; return 0; fi
  done
  return 1
}

ensure_homebrew() {
  local brew_bin installer shellenv
  [[ "$PLATFORM" == macos ]] || return 0
  if ! brew_bin=$(find_homebrew); then
    if [[ "$DRY_RUN" == 1 ]]; then
      log_dry 'Homebrew would be installed before missing macOS dependencies'
      return 0
    fi
    log_install Homebrew
    installer=$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh) || return 1
    /bin/bash -c "$installer" || return 1
    brew_bin=$(find_homebrew) || { log_fail 'Homebrew not found after installation'; return 1; }
  fi
  # Preview may adjust this process's PATH, but never invokes brew shellenv.
  if [[ "$DRY_RUN" == 1 ]]; then
    export PATH="${brew_bin%/*}:$PATH"
  else
    shellenv=$("$brew_bin" shellenv) || return 1
    eval "$shellenv"
  fi
}
