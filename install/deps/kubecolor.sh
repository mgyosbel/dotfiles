#!/usr/bin/env bash
dep_name() { echo kubecolor; }
dep_requires() { if [[ "$PLATFORM" == linux ]]; then echo go; fi; }
kubecolor_bin_dir() {
  local workspace="${GOPATH:-$HOME/dev/go}"
  printf '%s\n' "${GOBIN:-${workspace%%:*}/bin}"
}
dep_is_installed() {
  is_installed kubecolor || [[ -x "$(kubecolor_bin_dir)/kubecolor" ]]
}
dep_install() {
  case "$PLATFORM" in
    macos) brew_install kubecolor ;;
    linux)
      local go_bin destination
      if is_installed go; then
        go_bin=$(command -v go)
      elif [[ -x /usr/local/go/bin/go ]]; then
        go_bin=/usr/local/go/bin/go
      else
        log_fail 'Go executable not found'
        return 1
      fi
      destination=$(kubecolor_bin_dir)
      [[ "$destination" == /* ]] || { log_fail 'GOBIN/GOPATH must resolve to an absolute path'; return 1; }
      mkdir -p "$destination" || return 1
      GOBIN="$destination" "$go_bin" install github.com/kubecolor/kubecolor@latest
      ;;
  esac
}
