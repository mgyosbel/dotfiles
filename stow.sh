#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$DOTFILES_DIR/packages"
TARGET="${HOME:-}"
PROFILE=""
APPLY=0
ACTION=--restow
PACKAGES=()

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: ./stow.sh [OPTIONS] [package...]

Preview GNU Stow operations. Use --apply to change symlinks.
With no packages or profile, select profiles/common.

Options:
  --apply           Apply after a successful simulation of all selected packages
  --delete          Unstow selected packages instead of restowing them
  --profile NAME    Select a package list from profiles/ (exclusive with packages)
  --target DIR      Existing target directory (default: $HOME)
  --list            List available packages and profiles, then exit
  --help            Show this help, then exit
  --                End options

Examples:
  ./stow.sh
  ./stow.sh nvim tmux
  ./stow.sh --apply nvim tmux
  ./stow.sh --profile desktop
  ./stow.sh --apply --delete nvim
  ./stow.sh --target /path/to/test-home nvim
EOF
}

valid_name() {
  [[ "$1" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]
}

list_available() {
  local entry
  printf 'Packages:\n'
  for entry in "$STOW_DIR"/*; do
    [[ -d "$entry" ]] || continue
    printf '  %s\n' "${entry##*/}"
  done
  printf 'Profiles:\n'
  for entry in "$DOTFILES_DIR/profiles"/*; do
    [[ -f "$entry" ]] || continue
    printf '  %s\n' "${entry##*/}"
  done
}

add_package() {
  local name="$1" existing
  valid_name "$name" || die "Invalid package name: $name"
  [[ -d "$STOW_DIR/$name" ]] || die "Package not found: $name"
  # The conditional expansion handles empty arrays under Bash 3.2 + nounset.
  for existing in "${PACKAGES[@]+"${PACKAGES[@]}"}"; do
    [[ "$existing" != "$name" ]] || return 0
  done
  PACKAGES+=("$name")
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help) usage; exit 0 ;;
    --list) list_available; exit 0 ;;
    --apply) APPLY=1; shift ;;
    --delete) ACTION=--delete; shift ;;
    --profile)
      [[ $# -ge 2 && -n "$2" ]] || die "--profile requires a name"
      [[ -z "$PROFILE" ]] || die "Select only one profile"
      PROFILE="$2"
      shift 2
      ;;
    --target)
      [[ $# -ge 2 && -n "$2" ]] || die "--target requires a directory"
      TARGET="$2"
      shift 2
      ;;
    --)
      shift
      for package in "$@"; do add_package "$package"; done
      break
      ;;
    -*) die "Unknown option: $1" ;;
    *) add_package "$1"; shift ;;
  esac
done

if [[ -n "$PROFILE" && ${#PACKAGES[@]} -gt 0 ]]; then
  die "Choose either --profile or explicit packages"
fi
if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  PROFILE="${PROFILE:-common}"
  valid_name "$PROFILE" || die "Invalid profile name: $PROFILE"
  profile_file="$DOTFILES_DIR/profiles/$PROFILE"
  [[ -f "$profile_file" && -r "$profile_file" ]] || die "Profile not readable: $PROFILE"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    name="" extra=""
    read -r name extra <<< "$line"
    [[ -n "$name" ]] || continue
    [[ -z "$extra" ]] || die "Expected one package per line in $PROFILE: $line"
    add_package "$name"
  done < "$profile_file"
fi
[[ ${#PACKAGES[@]} -gt 0 ]] || die "No packages selected"
[[ -n "$TARGET" && -d "$TARGET" ]] || die "Target must be an existing directory: $TARGET"
TARGET="$(cd "$TARGET" && pwd -P)"
[[ "$TARGET" != "$DOTFILES_DIR" && "$TARGET" != "$DOTFILES_DIR/"* ]] ||
  die "Target must be outside the dotfiles repository"
command -v stow >/dev/null 2>&1 || die "GNU Stow is required (brew install stow / sudo apt-get install stow)"

# One invocation lets Stow detect conflicts across all selected packages.
# Keep directories real; link files rather than folding entire directory trees.
cd "$DOTFILES_DIR"
STOW_ARGS=(--dir="$STOW_DIR" --target="$TARGET" --no-folding --verbose "$ACTION")
printf 'Preview %s: %s\nTarget: %s\n' "${ACTION#--}" "${PACKAGES[*]}" "$TARGET"
if ! stow --simulate "${STOW_ARGS[@]}" "${PACKAGES[@]}"; then
  die "Stow preflight failed. Review the reported destinations before retrying."
fi
if [[ "$APPLY" -eq 0 ]]; then
  printf 'Preview complete. Re-run with --apply to change symlinks.\n'
  exit 0
fi

stow "${STOW_ARGS[@]}" "${PACKAGES[@]}"
printf 'Completed %s: %s\n' "${ACTION#--}" "${PACKAGES[*]}"
