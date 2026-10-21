() {
  local directory
  for directory in /usr/local/go/bin /opt/nvim-linux-x86_64/bin /opt/nvim-linux-arm64/bin; do
    [[ -d "$directory" ]] && path+=("$directory")
  done
}
if (( ! $+commands[bat] && $+commands[batcat] )); then
  alias bat=batcat
fi
return 0
