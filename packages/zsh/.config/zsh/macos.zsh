() {
  local prefix="${HOMEBREW_PREFIX:-}" directory
  local -a pkg_paths
  if [[ -n "$prefix" ]]; then
    [[ -d "$prefix/opt/libpq/bin" ]] && path=("$prefix/opt/libpq/bin" $path)
    for directory in "$prefix/lib/pkgconfig" "$prefix/share/pkgconfig"; do
      [[ -d "$directory" ]] && pkg_paths+=("$directory")
    done
  fi
  [[ -n "${PKG_CONFIG_PATH:-}" ]] && pkg_paths+=("${(@s/:/)PKG_CONFIG_PATH}")
  typeset -U pkg_paths
  (( ${#pkg_paths} )) && export PKG_CONFIG_PATH="${(j/:/)pkg_paths}"
}
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)
return 0
