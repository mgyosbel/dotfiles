#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# Resolve dotfiles root (works from any CWD)
# ─────────────────────────────────────────────
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# ─────────────────────────────────────────────
# Bootstrap shared lib
# ─────────────────────────────────────────────
# shellcheck source=install/lib/common.sh
source "$DOTFILES_DIR/install/lib/common.sh"
# shellcheck source=install/lib/registry.sh
source "$DOTFILES_DIR/install/lib/registry.sh"

# ─────────────────────────────────────────────
# Usage
# ─────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: ./install.sh [OPTIONS] [dep...]

Install dotfile dependencies on macOS (brew) or Linux (apt).

OPTIONS
  --list       List all available dependencies and exit
  --dry-run    Show what would be installed without making changes
  --help       Show this help and exit

EXAMPLES
  ./install.sh                  Install everything
  ./install.sh neovim tmux      Install only neovim and tmux
  ./install.sh --dry-run        Preview what would be installed
  ./install.sh --list           Print all available dep names
EOF
}

# ─────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────
SELECTED_DEPS=()

for arg in "$@"; do
  case "$arg" in
    --help)    usage; exit 0 ;;
    --list)    list_deps; exit 0 ;;
    --dry-run) export DRY_RUN=1 ;;
    --*)
      echo -e "${RED}Unknown option: $arg${NC}"
      usage
      exit 1
      ;;
    *)
      SELECTED_DEPS+=("$arg")
      ;;
  esac
done

# ─────────────────────────────────────────────
# Validate positional dep names
# ─────────────────────────────────────────────
if [[ ${#SELECTED_DEPS[@]} -gt 0 ]]; then
  for name in "${SELECTED_DEPS[@]}"; do
    valid=0
    for known in "${ALL_DEPS[@]}"; do
      [[ "$name" == "$known" ]] && valid=1 && break
    done
    if [[ $valid -eq 0 ]]; then
      echo -e "${RED}Unknown dep: '$name'${NC}. Run ./install.sh --list to see available deps."
      exit 1
    fi
  done
else
  SELECTED_DEPS=("${ALL_DEPS[@]}")
fi

# ─────────────────────────────────────────────
# macOS: ensure Homebrew is present
# ─────────────────────────────────────────────
if [[ "$PLATFORM" == "macos" ]] && ! is_installed brew; then
  log_install "Homebrew (required on macOS)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ─────────────────────────────────────────────
# Run selected deps
# ─────────────────────────────────────────────
[[ "$DRY_RUN" == "1" ]] && log_info "Dry-run mode — no changes will be made."
log_info "Platform: $PLATFORM"
echo ""

for dep in "${SELECTED_DEPS[@]}"; do
  run_dep "$dep" || true  # failures tracked inside run_dep; don't abort the loop
done

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
print_summary
