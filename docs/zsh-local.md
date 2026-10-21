# Zsh configuration and local migration

The Zsh package mirrors `$HOME`: fragments are deployed to `~/.config/zsh`.
`ZSH_CONFIG_DIR` can select a different fragment location if you manage its
deployment yourself. Setting `XDG_CONFIG_HOME` alone does not relocate Stow files.
Caches respect `XDG_CACHE_HOME`; K9s and envman respect `XDG_CONFIG_HOME`.

## Load order

Login shells read `.zprofile`: shared environment, optional `.zprofile.local`,
then the welcome banner only for an interactive terminal. Interactive shells
read `.zshrc` independently; `.zprofile` does not source it.

1. Existing `~/.zshrc.local` (early settings, credentials, plugin preferences).
2. `environment.zsh` (Homebrew discovery, defaults and deduplicated PATH).
3. `macos.zsh` or `linux.zsh` selected by Zsh's `OSTYPE`.
4. `common.zsh` (installed Oh My Zsh plugins or fallback compinit, aliases, tools,
   cached Starship/rbenv initialization, man-page colors).
5. `completions.zsh` (available tools, then standalone highlighting fallback).
6. Optional `~/.config/zsh/local.zsh` for final overrides.

The final override file is local to the machine and must never be added to the
Stow package. Its parent remains a real directory thanks to `--no-folding`.
Existing `.zshrc.local` content should be merged deliberately, not overwritten.
Creating or editing these live files requires a separate approval before activation.

## Settings to migrate on this Mac

These snippets preserve settings found in the live shell. Review them during
activation and merge the applicable ones into `~/.zshrc.local` (early exports) or
`~/.config/zsh/local.zsh` (aliases and integrations). They are documentation only.

### Early exports

```zsh
export GOPRIVATE=code.bbraun.io
export SOFTHSM2_CONF="$HOME/softhsm2/softhsm2.conf"
```

Existing proxy/CA settings belong in the early local file when needed. The proxy
examples in the inspected `.zshrc` were commented out; do not enable them merely
because the configuration is being migrated. Preserve existing credentials from
the local file without copying them into the repository.

### Machine-specific aliases

```zsh
alias offline='networksetup -setairportpower en0 off && sudo ifconfig en13 down'
alias online='networksetup -setairportpower en0 on && sudo ifconfig en13 up'
alias grafana-admin-user="kubectl get secret prometheus-stack-grafana -o jsonpath='{.data.admin-user}' -n monitoring | base64 --decode; echo"
alias grafana-admin-pass="kubectl get secret prometheus-stack-grafana -o jsonpath='{.data.admin-password}' -n monitoring | base64 --decode; echo"
```

Network interface names are specific to this machine. Keep these aliases local.

### SDK and development checkout paths

```zsh
local_sdk="$HOME/obsidian-vault/google-cloud-sdk"
[[ -r "$local_sdk/path.zsh.inc" ]] && source "$local_sdk/path.zsh.inc"
[[ -r "$local_sdk/completion.zsh.inc" ]] && source "$local_sdk/completion.zsh.inc"
unset local_sdk

local_opencode="$HOME/dev/pp/opencode/packages/opencode/node_modules/@opencode-ai/opencode-darwin-arm64/bin"
[[ -d "$local_opencode" ]] && path=("$local_opencode" $path)
unset local_opencode
```

The shared config includes the normal `~/.opencode/bin` path; the checkout above
is an optional machine-specific override. Homebrew/libpq discovery replaces the
hardcoded Apple Silicon prefix. The old internal Homebrew macOS-version-specific
pkg-config directory is not carried forward; add a local override only if a
particular build still requires it.

## Defaults and optional tools

`GOPATH` defaults to `$HOME/dev/go`; `tms` launches the tmux sessionizer. Starship
loads when installed. Set `plugins=(...)`, `ZSH`, `ZSH_CUSTOM`, or `ZSH_THEME` in
the early local file to override defaults. Missing plugin files are skipped.
The existing `ZSH_DISABLE_COMPFIX=true` preference is retained; fallback compinit
uses `-i` to ignore insecure completion directories without prompting.

Tool initialization caches include the executable path and arguments and refresh
when the binary is newer. Failed, empty, or syntactically invalid generation does
not replace a working cache. Remove a particular cache file to force regeneration
after changing tool configuration that is not reflected in its executable.
Missing executables are skipped even if an old cache exists.

On startup, optional installed tools may write their own caches or state. Tests
use an isolated home and controlled tool stubs, not the live configuration.
