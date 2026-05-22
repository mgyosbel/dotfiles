#!/usr/bin/env bash
# install/deps/rust.sh

dep_name()         { echo "rust/cargo"; }
dep_is_installed() { is_installed cargo; }
dep_install() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  log_info "Rust installed — ensure \$HOME/.cargo/bin is in your PATH."
}
