#!/usr/bin/env bash
# install/lib/registry.sh
# Canonical dep list, run_dep dispatcher, and summary printer.
# Sourced by install.sh — not executed directly.

# ─────────────────────────────────────────────
# Canonical install order
# ─────────────────────────────────────────────
ALL_DEPS=(
  curl
  git
  zsh
  stow
  neovim
  tmux
  fzf
  bat
  go
  rust
  kubectl
  kubecolor
  nvm
  oh-my-zsh
  zsh-syntax-highlighting
  zsh-completions
  ghostty
)

# ─────────────────────────────────────────────
# Result tracking (populated by run_dep)
# ─────────────────────────────────────────────
_INSTALLED=()
_SKIPPED=()
_FAILED=()

# ─────────────────────────────────────────────
# run_dep <name>
#
# Sources deps/<name>.sh in a subshell for isolation.
# Checks dep_platforms, dep_requires, dep_is_installed,
# then calls dep_install (or dry-run logs it).
# ─────────────────────────────────────────────
run_dep() {
  local name="$1"
  local dep_file="$DOTFILES_DIR/install/deps/${name}.sh"

  if [[ ! -f "$dep_file" ]]; then
    log_fail "$name — dep file not found: $dep_file"
    _FAILED+=("$name")
    return 1
  fi

  # Run everything in a subshell for isolation.
  # The subshell exits with:
  #   0 = installed or skipped (success)
  #   2 = skipped (platform mismatch or already installed)
  #   1 = failed
  local result
  result=$(
    set -e
    # shellcheck source=/dev/null
    source "$DOTFILES_DIR/install/lib/common.sh"
    # shellcheck source=/dev/null
    source "$dep_file"

    local dname
    dname="$(dep_name)"

    # ── Platform check ──────────────────────────
    if declare -f dep_platforms &>/dev/null; then
      local platforms
      mapfile -t platforms < <(dep_platforms)
      local supported=0
      for p in "${platforms[@]}"; do
        [[ "$p" == "$PLATFORM" ]] && supported=1 && break
      done
      if [[ $supported -eq 0 ]]; then
        log_skip "$dname (not supported on $PLATFORM)"
        exit 2
      fi
    fi

    # ── Requires check ──────────────────────────
    if declare -f dep_requires &>/dev/null; then
      local reqs
      mapfile -t reqs < <(dep_requires)
      for req in "${reqs[@]}"; do
        local req_file="$DOTFILES_DIR/install/deps/${req}.sh"
        if [[ ! -f "$req_file" ]]; then
          log_fail "$dname — required dep '$req' has no dep file"
          exit 1
        fi
        # Source req in a nested subshell just to call dep_is_installed
        local req_ok
        req_ok=$(
          source "$DOTFILES_DIR/install/lib/common.sh"
          source "$req_file"
          dep_is_installed && echo "yes" || echo "no"
        )
        if [[ "$req_ok" != "yes" ]]; then
          log_fail "$dname — required dep '$req' is not installed. Run: ./install.sh $req"
          exit 1
        fi
      done
    fi

    # ── Already installed? ───────────────────────
    if dep_is_installed; then
      log_skip "$dname"
      exit 2
    fi

    # ── Dry-run ─────────────────────────────────
    if [[ "$DRY_RUN" == "1" ]]; then
      log_dry "$dname — would install"
      exit 0
    fi

    # ── Install ─────────────────────────────────
    log_install "$dname"
    if dep_install; then
      exit 0
    else
      log_fail "$dname — installation failed"
      exit 1
    fi
  )
  local exit_code=$?

  # Print subshell output
  echo "$result"

  case $exit_code in
    0) _INSTALLED+=("$name") ;;
    2) _SKIPPED+=("$name") ;;
    *) _FAILED+=("$name") ;;
  esac

  return $exit_code
}

# ─────────────────────────────────────────────
# print_summary
# ─────────────────────────────────────────────
print_summary() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " Install Summary"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "${GREEN}Installed (${#_INSTALLED[@]}):${NC} ${_INSTALLED[*]:-none}"
  echo -e "${CYAN}Skipped   (${#_SKIPPED[@]}):${NC} ${_SKIPPED[*]:-none}"
  echo -e "${RED}Failed    (${#_FAILED[@]}):${NC} ${_FAILED[*]:-none}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if [[ ${#_FAILED[@]} -gt 0 ]]; then
    echo -e "${RED}Some dependencies failed. Review the output above.${NC}"
    return 1
  fi

  echo -e "${GREEN}All done.${NC}"
}

# ─────────────────────────────────────────────
# list_deps — prints all available dep names
# ─────────────────────────────────────────────
list_deps() {
  echo -e "${BOLD}Available dependencies:${NC}"
  for name in "${ALL_DEPS[@]}"; do
    local dep_file="$DOTFILES_DIR/install/deps/${name}.sh"
    if [[ -f "$dep_file" ]]; then
      echo "  $name"
    else
      echo -e "  ${RED}$name${NC} (missing dep file)"
    fi
  done
}
