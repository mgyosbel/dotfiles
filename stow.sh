#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

LINKED=()
RESTOWED=()
CONFLICTS=()

log_linked()   { echo -e "${GREEN}[LINKED]${NC}    $1"; }
log_restowed() { echo -e "${CYAN}[RESTOWED]${NC}  $1"; }
log_conflict() { echo -e "${RED}[CONFLICT]${NC}  $1"; }
log_info()     { echo -e "${YELLOW}[INFO]${NC}      $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────────
# Check stow is available
# ─────────────────────────────────────────────
if ! command -v stow &>/dev/null; then
  echo -e "${RED}stow is not installed. Run ./install.sh first.${NC}"
  exit 1
fi

# ─────────────────────────────────────────────
# Packages to stow
# ─────────────────────────────────────────────
PACKAGES=(zsh nvim tmux ghostty)

# ─────────────────────────────────────────────
# For each package, find the top-level targets
# stow would create and check for real-file conflicts
# ─────────────────────────────────────────────
has_conflict() {
  local package="$1"
  local package_dir="$DOTFILES_DIR/$package"
  local conflict=0

  # Walk top-level entries inside the package dir
  for entry in "$package_dir"/.*  "$package_dir"/*; do
    # skip . and ..
    [[ "$(basename "$entry")" == "." || "$(basename "$entry")" == ".." ]] && continue
    [[ ! -e "$entry" ]] && continue

    local rel="${entry#$package_dir/}"
    local target="$HOME/$rel"

    if [[ -e "$target" && ! -L "$target" ]]; then
      log_conflict "$package: $target is a real file/directory — back it up and remove it, then re-run."
      CONFLICTS+=("$target")
      conflict=1
    fi
  done

  return $conflict
}

is_already_stowed() {
  local package="$1"
  local package_dir="$DOTFILES_DIR/$package"

  for entry in "$package_dir"/.*  "$package_dir"/*; do
    [[ "$(basename "$entry")" == "." || "$(basename "$entry")" == ".." ]] && continue
    [[ ! -e "$entry" ]] && continue

    local rel="${entry#$package_dir/}"
    local target="$HOME/$rel"

    # If at least one target is a symlink pointing into our dotfiles, consider it stowed
    if [[ -L "$target" ]]; then
      local link_dest
      link_dest="$(readlink "$target")"
      if [[ "$link_dest" == "$DOTFILES_DIR"* || "$link_dest" == *"dotfiles"* ]]; then
        return 0
      fi
    fi
  done

  return 1
}

# ─────────────────────────────────────────────
# Main loop
# ─────────────────────────────────────────────
cd "$DOTFILES_DIR"

for pkg in "${PACKAGES[@]}"; do
  if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
    log_info "$pkg — package directory not found, skipping."
    continue
  fi

  if has_conflict "$pkg"; then
    # conflict already logged inside has_conflict
    continue
  fi

  if is_already_stowed "$pkg"; then
    stow -R --target="$HOME" "$pkg"
    log_restowed "$pkg"
    RESTOWED+=("$pkg")
  else
    stow --target="$HOME" "$pkg"
    log_linked "$pkg"
    LINKED+=("$pkg")
  fi
done

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Stow Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Linked    (${#LINKED[@]}):${NC} ${LINKED[*]:-none}"
echo -e "${CYAN}Restowed  (${#RESTOWED[@]}):${NC} ${RESTOWED[*]:-none}"
echo -e "${RED}Conflicts (${#CONFLICTS[@]}):${NC} ${CONFLICTS[*]:-none}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ ${#CONFLICTS[@]} -gt 0 ]]; then
  echo -e "${RED}Resolve conflicts above, then re-run ./stow.sh.${NC}"
  exit 1
fi

echo -e "${GREEN}Done. All packages symlinked successfully.${NC}"
