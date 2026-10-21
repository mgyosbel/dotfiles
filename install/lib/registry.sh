#!/usr/bin/env bash
# Bash 3.2-compatible dependency graph and dispatcher.
ALL_DEPS=(curl git zsh stow neovim tmux tpm fzf bat starship go rust kubectl kubecolor nvm
          oh-my-zsh zsh-syntax-highlighting zsh-completions zsh-autosuggestions ghostty)
ORDERED=()
VISITING=()
RESOLVED=()
_INSTALLED=()
_PLANNED=()
_SKIPPED=()
_FAILED=()
_UNSUPPORTED=()

contains() {
  local wanted=$1 item
  shift
  for item in "$@"; do [[ "$item" != "$wanted" ]] || return 0; done
  return 1
}

validate_dep() {
  contains "$1" "${ALL_DEPS[@]}" || { log_fail "Unknown dependency: $1"; return 1; }
  [[ -r "$DOTFILES_DIR/install/deps/$1.sh" ]] || { log_fail "Missing module: $1"; return 1; }
}

# Fresh Bash processes isolate module functions and preserve errexit inside
# dep_install, even though the parent examines the process's return status.
module_call() {
  local name=$1 operation=$2
  # The child Bash expands this script.
  # shellcheck disable=SC2016
  "$BASH" -euo pipefail -c '
    source "$DOTFILES_DIR/install/lib/common.sh"
    source "$DOTFILES_DIR/install/deps/$1.sh"
    case "$2" in
      requires) if declare -f dep_requires >/dev/null; then dep_requires; fi ;;
      platforms) if declare -f dep_platforms >/dev/null; then dep_platforms; fi ;;
      check) dep_is_installed ;;
      install)
        dep_install
        if ! dep_is_installed; then
          log_fail "$1: post-install check failed"
          exit 1
        fi
        ;;
    esac
  ' module "$name" "$operation"
}

supported_dep() {
  local values p
  values=$(module_call "$1" platforms) || return 1
  [[ -n "$values" ]] || return 0
  while IFS= read -r p; do [[ "$p" != "$PLATFORM" ]] || return 0; done <<< "$values"
  return 2
}

resolve_dep() {
  local name=$1 requirements req index support_status
  validate_dep "$name" || return 1
  contains "$name" "${RESOLVED[@]+"${RESOLVED[@]}"}" && return 0
  if contains "$name" "${VISITING[@]+"${VISITING[@]}"}"; then
    log_fail "Dependency cycle at $name"
    return 1
  fi
  VISITING+=("$name")
  # Unsupported top-level modules are reported as skips, not installed.
  if supported_dep "$name"; then
    requirements=$(module_call "$name" requires) || return 1
    while IFS= read -r req; do
      [[ -n "$req" ]] || continue
      validate_dep "$req" || return 1
      if ! supported_dep "$req"; then
        log_fail "$name requires $req, which does not support $PLATFORM"
        return 1
      fi
      resolve_dep "$req" || return 1
    done <<< "$requirements"
  else
    support_status=$?
    [[ "$support_status" -eq 2 ]] || { log_fail "Failed reading platform metadata: $name"; return 1; }
    _UNSUPPORTED+=("$name")
  fi
  index=$((${#VISITING[@]} - 1))
  unset "VISITING[$index]"
  RESOLVED+=("$name")
  ORDERED+=("$name")
}

run_dep() {
  local name=$1 requirements req
  if contains "$name" "${_UNSUPPORTED[@]+"${_UNSUPPORTED[@]}"}"; then
    log_skip "$name (unsupported on $PLATFORM)"
    _SKIPPED+=("$name")
    return 0
  fi
  if module_call "$name" check; then
    log_skip "$name (already installed)"
    _SKIPPED+=("$name")
    return 0
  fi
  requirements=$(module_call "$name" requires) || { _FAILED+=("$name"); return 1; }
  while IFS= read -r req; do
    [[ -n "$req" ]] || continue
    if contains "$req" "${_FAILED[@]+"${_FAILED[@]}"}"; then
      log_fail "$name blocked by failed prerequisite $req"
      _FAILED+=("$name")
      return 1
    fi
  done <<< "$requirements"
  if [[ "$DRY_RUN" == 1 ]]; then
    log_dry "$name would be installed"
    _PLANNED+=("$name")
  elif module_call "$name" install; then
    log_install "$name completed"
    _INSTALLED+=("$name")
  else
    log_fail "$name installation failed"
    _FAILED+=("$name")
    return 1
  fi
}

print_summary() {
  printf '\nInstalled (%s): %s\n' "${#_INSTALLED[@]}" "${_INSTALLED[*]:-none}"
  printf 'Planned   (%s): %s\n' "${#_PLANNED[@]}" "${_PLANNED[*]:-none}"
  printf 'Skipped   (%s): %s\n' "${#_SKIPPED[@]}" "${_SKIPPED[*]:-none}"
  printf 'Failed    (%s): %s\n' "${#_FAILED[@]}" "${_FAILED[*]:-none}"
  [[ ${#_FAILED[@]} -eq 0 ]]
}

list_deps() { printf '%s\n' "${ALL_DEPS[@]}"; }
