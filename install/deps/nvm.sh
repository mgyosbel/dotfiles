#!/usr/bin/env bash
# install/deps/nvm.sh

dep_name()         { echo "nvm"; }
dep_is_installed() { [[ -d "$HOME/.nvm" ]]; }
dep_install() {
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | PROFILE=/dev/null bash
  log_info "nvm installed — it will be activated on next shell start via .zshrc."
}
