# Oh My Zsh or the fallback compinit has already defined compdef.
_load_cached nats nats --completion-script-zsh || true
_load_cached kubectl kubectl completion zsh || true
_load_cached kubie kubie generate-completion || true
if (( $+commands[kubecolor] )); then
  alias kubectl=kubecolor
  alias k=kubecolor
  [[ -n "${_comps[kubectl]:-}" ]] && compdef kubecolor=kubectl
elif (( $+commands[kubectl] )); then
  alias k=kubectl
fi

if (( $+commands[dotnet] )); then
  _dotnet_zsh_complete() {
    local output
    output=$(command dotnet complete --position "$CURSOR" "$BUFFER" 2>/dev/null) || return 1
    local -a candidates=("${(@f)output}")
    if [[ -n "$output" ]]; then
      compadd -- "${candidates[@]}"
    else
      _files
    fi
  }
  compdef _dotnet_zsh_complete dotnet
fi

if (( $+commands[cargo])); then
  source <(CARGO_COMPLETE=zsh cargo +nightly)
fi

if ! _load_cached fzf fzf --zsh; then
  if [[ -r "$HOME/.fzf.zsh" ]]; then
    source "$HOME/.fzf.zsh"
  elif [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -r /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
  fi
fi
if (( $+commands[terraform] )); then
  autoload -Uz bashcompinit
  bashcompinit
  complete -o nospace -C "$commands[terraform]" terraform
fi
# Support the old installer's standalone checkout until bootstrap is reconciled.
if (( ! ${plugins[(Ie)zsh-syntax-highlighting]} )) &&
    [[ -r "$HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
return 0
