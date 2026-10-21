#!/usr/bin/env bash
dep_name() { echo tpm; }
dep_requires() { printf '%s\n' git tmux; }
dep_is_installed() { [[ -x "$HOME/.tmux/plugins/tpm/tpm" ]]; }
dep_install() {
  git_clone_if_missing https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm"
}
