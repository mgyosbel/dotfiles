# Interactive settings; the deployed fragments live alongside the Stow package.
[[ -o interactive ]] || return 0
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
source "$ZSH_CONFIG_DIR/environment.zsh"
case "$OSTYPE" in
  darwin*) source "$ZSH_CONFIG_DIR/macos.zsh" ;;
  linux*) source "$ZSH_CONFIG_DIR/linux.zsh" ;;
esac
source "$ZSH_CONFIG_DIR/common.zsh"
source "$ZSH_CONFIG_DIR/completions.zsh"
[[ -r "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
return 0
