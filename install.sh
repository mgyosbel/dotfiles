#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

INSTALLED=()
SKIPPED=()
FAILED=()

log_install() { echo -e "${GREEN}[INSTALL]${NC} $1"; }
log_skip()    { echo -e "${CYAN}[SKIP]${NC}    $1"; }
log_fail()    { echo -e "${RED}[FAIL]${NC}    $1"; }
log_info()    { echo -e "${YELLOW}[INFO]${NC}    $1"; }

# ─────────────────────────────────────────────
# OS Detection
# ─────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)
    echo -e "${RED}Unsupported OS: $OS${NC}"
    exit 1
    ;;
esac

log_info "Detected platform: $PLATFORM"

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────
is_installed() {
  command -v "$1" &>/dev/null
}

# Install a package by name. Accepts:
#   install_pkg <check_cmd> <brew_pkg> <apt_pkg> [description]
install_pkg() {
  local check="$1"
  local brew_pkg="$2"
  local apt_pkg="$3"
  local desc="${4:-$check}"

  if is_installed "$check"; then
    log_skip "$desc"
    SKIPPED+=("$desc")
    return
  fi

  log_install "$desc"
  if [[ "$PLATFORM" == "macos" ]]; then
    brew install "$brew_pkg" && INSTALLED+=("$desc") || { log_fail "$desc"; FAILED+=("$desc"); }
  else
    sudo apt-get install -y "$apt_pkg" && INSTALLED+=("$desc") || { log_fail "$desc"; FAILED+=("$desc"); }
  fi
}

# ─────────────────────────────────────────────
# macOS: Homebrew
# ─────────────────────────────────────────────
if [[ "$PLATFORM" == "macos" ]]; then
  if ! is_installed brew; then
    log_install "Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    INSTALLED+=("Homebrew")
  else
    log_skip "Homebrew"
    SKIPPED+=("Homebrew")
  fi
fi

# ─────────────────────────────────────────────
# Linux: apt update
# ─────────────────────────────────────────────
if [[ "$PLATFORM" == "linux" ]]; then
  log_info "Updating apt package index..."
  sudo apt-get update -qq
fi

# ─────────────────────────────────────────────
# Core packages
# ─────────────────────────────────────────────
install_pkg git       git       git       "git"
install_pkg zsh       zsh       zsh       "zsh"
install_pkg stow      stow      stow      "stow"
install_pkg nvim      neovim    neovim    "neovim"
install_pkg tmux      tmux      tmux      "tmux"
install_pkg fzf       fzf       fzf       "fzf"

# bat: binary is 'batcat' on Debian/Ubuntu, 'bat' on macOS
if [[ "$PLATFORM" == "macos" ]]; then
  install_pkg bat  bat  bat  "bat"
else
  if is_installed batcat || is_installed bat; then
    log_skip "bat"
    SKIPPED+=("bat")
  else
    log_install "bat"
    sudo apt-get install -y bat && INSTALLED+=("bat") || { log_fail "bat"; FAILED+=("bat"); }
  fi
fi

# ─────────────────────────────────────────────
# Go
# ─────────────────────────────────────────────
if is_installed go; then
  log_skip "Go"
  SKIPPED+=("Go")
else
  log_install "Go"
  if [[ "$PLATFORM" == "macos" ]]; then
    brew install go && INSTALLED+=("Go") || { log_fail "Go"; FAILED+=("Go"); }
  else
    GO_VERSION="1.22.3"
    GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz"
    curl -fsSL "https://go.dev/dl/${GO_TARBALL}" -o "/tmp/${GO_TARBALL}"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "/tmp/${GO_TARBALL}"
    rm "/tmp/${GO_TARBALL}"
    log_info "Go installed to /usr/local/go. Ensure /usr/local/go/bin is in your PATH."
    INSTALLED+=("Go")
  fi
fi

# ─────────────────────────────────────────────
# Rust / Cargo
# ─────────────────────────────────────────────
if is_installed cargo; then
  log_skip "Rust/Cargo"
  SKIPPED+=("Rust/Cargo")
else
  log_install "Rust/Cargo"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  INSTALLED+=("Rust/Cargo")
fi

# ─────────────────────────────────────────────
# kubectl
# ─────────────────────────────────────────────
if is_installed kubectl; then
  log_skip "kubectl"
  SKIPPED+=("kubectl")
else
  log_install "kubectl"
  if [[ "$PLATFORM" == "macos" ]]; then
    brew install kubectl && INSTALLED+=("kubectl") || { log_fail "kubectl"; FAILED+=("kubectl"); }
  else
    KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /tmp/kubectl
    sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
    rm /tmp/kubectl
    INSTALLED+=("kubectl")
  fi
fi

# ─────────────────────────────────────────────
# kubecolor (requires Go)
# ─────────────────────────────────────────────
if is_installed kubecolor; then
  log_skip "kubecolor"
  SKIPPED+=("kubecolor")
else
  if ! is_installed go; then
    log_fail "kubecolor (Go not available — install Go first)"
    FAILED+=("kubecolor")
  else
    log_install "kubecolor"
    if [[ "$PLATFORM" == "macos" ]]; then
      brew install kubecolor && INSTALLED+=("kubecolor") || { log_fail "kubecolor"; FAILED+=("kubecolor"); }
    else
      go install github.com/kubecolor/kubecolor@latest && INSTALLED+=("kubecolor") || { log_fail "kubecolor"; FAILED+=("kubecolor"); }
    fi
  fi
fi

# ─────────────────────────────────────────────
# NVM
# ─────────────────────────────────────────────
if [[ -d "$HOME/.nvm" ]]; then
  log_skip "nvm"
  SKIPPED+=("nvm")
else
  log_install "nvm"
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | PROFILE=/dev/null bash
  INSTALLED+=("nvm")
fi

# ─────────────────────────────────────────────
# Oh My Zsh
# ─────────────────────────────────────────────
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  log_skip "oh-my-zsh"
  SKIPPED+=("oh-my-zsh")
else
  log_install "oh-my-zsh"
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  INSTALLED+=("oh-my-zsh")
fi

# ─────────────────────────────────────────────
# zsh-syntax-highlighting
# ─────────────────────────────────────────────
ZSH_SYNTAX_DIR="$HOME/zsh-syntax-highlighting"
if [[ -d "$ZSH_SYNTAX_DIR" ]]; then
  log_skip "zsh-syntax-highlighting"
  SKIPPED+=("zsh-syntax-highlighting")
else
  log_install "zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_DIR" \
    && INSTALLED+=("zsh-syntax-highlighting") \
    || { log_fail "zsh-syntax-highlighting"; FAILED+=("zsh-syntax-highlighting"); }
fi

# ─────────────────────────────────────────────
# zsh-completions
# ─────────────────────────────────────────────
ZSH_COMPLETIONS_DIR="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-completions"
if [[ -d "$ZSH_COMPLETIONS_DIR" ]]; then
  log_skip "zsh-completions"
  SKIPPED+=("zsh-completions")
else
  log_install "zsh-completions"
  git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_COMPLETIONS_DIR" \
    && INSTALLED+=("zsh-completions") \
    || { log_fail "zsh-completions"; FAILED+=("zsh-completions"); }
fi

# ─────────────────────────────────────────────
# Ghostty
# ─────────────────────────────────────────────
if is_installed ghostty; then
  log_skip "ghostty"
  SKIPPED+=("ghostty")
else
  if [[ "$PLATFORM" == "macos" ]]; then
    log_install "ghostty"
    brew install --cask ghostty && INSTALLED+=("ghostty") || { log_fail "ghostty"; FAILED+=("ghostty"); }
  else
    log_info "ghostty — Linux install is distro-specific. Please install manually: https://ghostty.org/docs/install"
    SKIPPED+=("ghostty (manual)")
  fi
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Install Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Installed (${#INSTALLED[@]}):${NC} ${INSTALLED[*]:-none}"
echo -e "${CYAN}Skipped   (${#SKIPPED[@]}):${NC} ${SKIPPED[*]:-none}"
echo -e "${RED}Failed    (${#FAILED[@]}):${NC} ${FAILED[*]:-none}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo -e "${RED}Some dependencies failed. Review the output above.${NC}"
  exit 1
fi

echo -e "${GREEN}All dependencies ready. Run ./stow.sh to set up symlinks.${NC}"
