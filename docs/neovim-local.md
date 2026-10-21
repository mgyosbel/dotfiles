# Machine-local Neovim settings

Shared options load an optional `local.lua` from `vim.fn.stdpath("config")`.
Normally this is `~/.config/nvim/local.lua`; Neovim resolves custom XDG/app-name
settings through `stdpath`. Stow still deploys this package to `~/.config/nvim`,
so a nondefault Neovim configuration directory requires deployment planning.

## Load order

`lua/config/options.lua` applies shared defaults, enables Copilot, and then runs
`local.lua` if it is readable. The installed LazyVim implementation loads user
options during configuration initialization, before plugin initialization.
Consequently, machine-local variables are available when Copilot starts. Use
this hook for early options and variables, not calls into plugins that have not
loaded yet. Syntax/runtime errors in a present local file are surfaced rather
than silently ignored.

## Preserve this Mac's enterprise configuration

Before activating the shared package, create or merge the following into the
live `~/.config/nvim/local.lua` with separate explicit approval:

```lua
vim.g.copilot_enterprise_uri = "https://bbraun.ghe.com"
vim.g.copilot_proxy = "http://localhost:9000"
vim.g.copilot_proxy_strict_ssl = false
```

These reproduce the three assignments from the previous live/shared config.
Other machines can omit the file, supply their own endpoint/proxy settings, or
set `vim.g.copilot_enabled = false` locally. Shared options do not clear variables
already supplied through another initialization mechanism.

Keep `local.lua` as a real machine-local file in the deployed config directory,
not in the Stow package. The repository ignore rule prevents accidental Git
tracking at the package path, but Git ignores do not prevent Stow from deploying
an untracked file placed inside a package. Back up and preserve any existing
local file when reconciling the live Neovim directory.

The local file has not been created by repository preparation. No credentials
or machine-local `.env` files are imported through this hook.
