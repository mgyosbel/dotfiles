-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Resolve project Go versions even when Neovim is launched outside an activated shell.
-- Mason still provides editor tools; it does not install the Go compiler itself.
local mise_shims = vim.fs.joinpath(vim.env.MISE_DATA_DIR or (vim.fn.expand("~") .. "/.local/share/mise"), "shims")
if vim.fn.isdirectory(mise_shims) == 1 then
  vim.env.PATH = mise_shims .. ":" .. vim.env.PATH
end
vim.opt.colorcolumn = "120"
vim.opt.listchars = { tab = "| ", trail = "·", nbsp = "␣" }
vim.lsp.inlay_hint.enable(false)
vim.g.snacks_animate = false

-- colors
vim.opt.termguicolors = true
vim.g.syntax = "enable"
vim.o.winblend = 0

-- Enable Copilot; endpoint/proxy overrides belong to this machine's local.lua.
vim.g.copilot_enabled = true
local local_config = vim.fn.stdpath("config") .. "/local.lua"
if vim.fn.filereadable(local_config) == 1 then
  dofile(local_config)
end

-- LSP Server to use for Rust.
-- Set to "bacon-ls" to use bacon-ls instead of rust-analyzer.
-- only for diagnostics. The rest of LSP support will still be
-- provided by rust-analyzer.
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"
