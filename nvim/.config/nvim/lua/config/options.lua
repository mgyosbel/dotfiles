-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.colorcolumn = "120"
vim.opt.listchars = { tab = "| ", trail = "·", nbsp = "␣" }
vim.lsp.inlay_hint.enable(false)
vim.g.snacks_animate = false

-- colors
vim.opt.termguicolors = true
vim.g.syntax = 'enable'
vim.o.winblend = 0

-- Copilot Enterprise
vim.g.copilot_enabled = true
vim.g.copilot_enterprise_uri = 'https://bbraun.ghe.com'
vim.g.copilot_proxy = 'http://localhost:9000'
vim.g.copilot_proxy_strict_ssl = false

