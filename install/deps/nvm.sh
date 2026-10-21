#!/usr/bin/env bash
# install/deps/nvm.sh

dep_name()         { echo "nvm"; }
dep_requires() { echo curl; }
dep_is_installed() { [[ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]]; }
dep_install() {
  local installer dest="${NVM_DIR:-$HOME/.nvm}"
  installer=$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh) || return 1
  mkdir -p "$dest" || return 1
  # Script installation avoids an undeclared Git prerequisite. NVM does not
  # install Node itself; the shell loads nvm.sh after activation.
  NVM_DIR="$dest" PROFILE=/dev/null METHOD=script bash -c "$installer" || return 1
  dep_is_installed || { log_fail 'NVM installation did not produce nvm.sh'; return 1; }
  log_info "nvm installed — it will be activated on next shell start via .zshrc."
}
