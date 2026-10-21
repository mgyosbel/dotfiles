# Cache only successful, nonempty, syntactically valid tool initialization.
ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"
_load_cached() {
  emulate -L zsh
  local name=$1; shift
  local bin=${commands[$1]:-} cache="$ZSH_CACHE_DIR/$name.zsh" tmp header key
  [[ -n "$bin" && -x "$bin" ]] || return 1
  shift
  [[ "$name" =~ ^[a-zA-Z0-9_-]+$ ]] || return 1
  key="# ${(q)bin} ${(q)@}"
  [[ -r "$cache" ]] && IFS= read -r header < "$cache"
  if [[ ! -s "$cache" || "$bin" -nt "$cache" || "$header" != "$key" ]]; then
    command mkdir -p "$ZSH_CACHE_DIR" || return 1
    tmp=$(command mktemp "$ZSH_CACHE_DIR/$name.XXXXXXXX") || return 1
    if "$bin" "$@" > "$tmp" 2>/dev/null && [[ -s "$tmp" ]] &&
        command zsh -f -n "$tmp" >/dev/null 2>&1; then
      # Prefix a cache key without exposing a partially written file to readers.
      local output=$(<"$tmp")
      print -r -- "$key" >| "$tmp"
      print -r -- "$output" >> "$tmp"
      command mv -f "$tmp" "$cache" || { command rm -f "$tmp"; return 1; }
    else
      command rm -f "$tmp"
    fi
  fi
  [[ -s "$cache" ]] || return 1
  source "$cache"
}

COMPLETION_WAITING_DOTS="${COMPLETION_WAITING_DOTS:-true}"
ZSH_DISABLE_COMPFIX="${ZSH_DISABLE_COMPFIX:-true}"
ZSH_THEME="${ZSH_THEME-}"
() {
  local plugin custom="${ZSH_CUSTOM:-$ZSH/custom}"
  local -a requested
  if (( ${+plugins} )); then
    requested=("${plugins[@]}")
  else
    requested=(git docker zsh-completions zsh-autosuggestions zsh-syntax-highlighting)
  fi
  plugins=()
  for plugin in "${requested[@]}"; do
    if [[ -r "$custom/plugins/$plugin/$plugin.plugin.zsh" ||
          -r "$ZSH/plugins/$plugin/$plugin.plugin.zsh" ||
          -r "$custom/plugins/$plugin/_$plugin" || -r "$ZSH/plugins/$plugin/_$plugin" ]]; then
      plugins+=("$plugin")
    fi
  done
  [[ -d "$custom/plugins/zsh-completions/src" ]] && fpath=("$custom/plugins/zsh-completions/src" $fpath)
}
if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  autoload -Uz compinit
  compinit -i
fi

(( $+commands[python3] )) && alias python=python3
(( $+commands[nvim] )) && alias vim=nvim
(( $+commands[pip3] )) && alias pip=pip3
alias tms='"$HOME/.local/bin/tmux-sessionizer"'
alias cl='clear -x'

[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
[[ -s "${XDG_CONFIG_HOME:-$HOME/.config}/envman/load.sh" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/envman/load.sh"
_load_cached rbenv rbenv init - || true
_load_cached starship starship init zsh || true

export LESS_TERMCAP_mb=$'\e[1;31m' LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m' LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;33;44m' LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;1;32m' LESS_TERMCAP_mr=$'\e[7m'
export LESS_TERMCAP_mh=$'\e[2m' LESS_TERMCAP_ZN=$'\e[74m'
export LESS_TERMCAP_ZV=$'\e[75m' LESS_TERMCAP_ZO=$'\e[73m' LESS_TERMCAP_ZW=$'\e[75m'
export MANPAGER=less GROFF_NO_SGR=1
return 0
