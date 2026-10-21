#!/usr/bin/env bash
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR
# shellcheck source=install/lib/common.sh
source "$DOTFILES_DIR/install/lib/common.sh"
# shellcheck source=install/lib/registry.sh
source "$DOTFILES_DIR/install/lib/registry.sh"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run] [dependency...]

Install dependencies on macOS (Homebrew) or Debian/Ubuntu (apt).
Declared prerequisites are resolved before dependents. No selection means all.

  --dry-run  Report planned installations without running installers
  --list     List available dependencies
  --help     Show this help

Examples:
  ./install.sh --dry-run
  ./install.sh neovim tmux
EOF
}

SELECTED_DEPS=()
for arg in "$@"; do
  case "$arg" in
    --help) usage; exit 0 ;;
    --list) list_deps; exit 0 ;;
    --dry-run) DRY_RUN=1 ;;
    -*) log_fail "Unknown option: $arg"; exit 1 ;;
    *) SELECTED_DEPS+=("$arg") ;;
  esac
done
if [[ ${#SELECTED_DEPS[@]} -eq 0 ]]; then SELECTED_DEPS=("${ALL_DEPS[@]}"); fi
for name in "${SELECTED_DEPS[@]}"; do validate_dep "$name" || exit 1; done
detect_platform
for name in "${SELECTED_DEPS[@]}"; do resolve_dep "$name" || exit 1; done

# Keep user-level tools in the invoking user's home. Elevate individual system
# operations via as_root instead of executing the entire bootstrap with sudo.
if [[ "$DRY_RUN" != 1 && "$EUID" -eq 0 ]]; then
  log_fail 'Run install.sh as your normal user; system operations use sudo as needed.'
  exit 1
fi
ensure_homebrew
if [[ "$DRY_RUN" != 1 ]]; then
  INSTALL_STATE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-install.XXXXXXXX")
  export INSTALL_STATE_DIR
  trap 'rm -rf -- "$INSTALL_STATE_DIR"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
fi
log_info "Platform: $PLATFORM ($DISTRO), architecture: $ARCH"
[[ "$DRY_RUN" != 1 ]] || log_info 'Preview only; no installers or state-directory writes.'
for dep in "${ORDERED[@]}"; do run_dep "$dep" || true; done
print_summary
