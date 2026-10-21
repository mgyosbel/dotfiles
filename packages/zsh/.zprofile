# Login environment; interactive shells read .zshrc themselves afterward.
source "${ZSH_CONFIG_DIR:-$HOME/.config/zsh}/environment.zsh"
if [[ "$OSTYPE" == darwin* && -d /Library/Frameworks/Python.framework/Versions/3.13/bin ]]; then
  path=(/Library/Frameworks/Python.framework/Versions/3.13/bin $path)
fi
[[ -r "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"

if [[ -o interactive && -t 1 && "${TERM:-dumb}" != dumb ]]; then
  () {
    local width=${COLUMNS:-80} font=standard candidate
    (( width > 0 )) || width=80
    printf '%*s%s\n' $((width * 6 / 100)) '' "Let's rock and roll baby!"
    if (( $+commands[figlet] )); then
      for candidate in slant future standard mono12 smblock; do
        if command figlet -f "$candidate" '' >/dev/null 2>&1; then
          font=$candidate
          break
        fi
      done
      if (( $+commands[lolcat] )); then
        command figlet -w "$width" -f "$font" KYUUBI | command lolcat
      else
        command figlet -w "$width" -f "$font" KYUUBI
      fi
    fi
  }
fi
return 0
