# Shared by login and interactive shells. Preserve explicit local settings.
typeset -gU path fpath
export GOPATH="${GOPATH:-$HOME/dev/go}"
export EDITOR="${EDITOR:-nvim}"
export K9S_CONFIG_DIR="${K9S_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/k9s}"
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"

() {
  local brew_bin=${commands[brew]:-} candidate shellenv
  if [[ -z "$brew_bin" ]]; then
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
      if [[ -x "$candidate" ]]; then
        brew_bin=$candidate
        break
      fi
    done
  fi
  # Skip repeated shellenv calls once this shell has initialized this binary.
  if [[ -n "$brew_bin" && "${_DOTFILES_BREW_INITIALIZED:-}" != "$brew_bin" ]]; then
    if shellenv=$("$brew_bin" shellenv 2>/dev/null); then
      eval "$shellenv"
      typeset -g _DOTFILES_BREW_INITIALIZED=$brew_bin
    fi
  fi
}

path=("$HOME/bin" "$HOME/.local/bin" "$HOME/.cargo/bin" "$GOPATH/bin"
      "$HOME/.opencode/bin" "$BUN_INSTALL/bin" "$HOME/.rbenv/bin" $path "$HOME/.rvm/bin")
export PATH
return 0
