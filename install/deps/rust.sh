#!/usr/bin/env bash
# install/deps/rust.sh

dep_name()         { echo "rust/cargo"; }
dep_requires() { echo curl; }
dep_is_installed() {
  if is_installed cargo && cargo --version >/dev/null 2>&1; then return 0; fi
  [[ -x "${CARGO_HOME:-$HOME/.cargo}/bin/cargo" ]] &&
    "${CARGO_HOME:-$HOME/.cargo}/bin/cargo" --version >/dev/null 2>&1
}
dep_install() {
  local installer
  installer=$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs) || return 1
  sh -c "$installer" -- -y --no-modify-path || return 1
  dep_is_installed || { log_fail 'Rust installation did not produce a working Cargo'; return 1; }
  log_info "Rust installed — ensure \$HOME/.cargo/bin is in your PATH."
}
