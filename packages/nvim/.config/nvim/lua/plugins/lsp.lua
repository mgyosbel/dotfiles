-- Diagnostics backend used for Rust: "rust-analyzer" or "bacon-ls".
-- Configured in `lua/config/options.lua` via `vim.g.lazyvim_rust_diagnostics`.
local diagnostics = vim.g.lazyvim_rust_diagnostics or "rust-analyzer"

return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      enabled = false,
      exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
    },
    servers = {
      terraformls = {},
      dockerls = {
        enabled = false,
      },
      bacon_ls = {
        enabled = diagnostics == "bacon-ls",
      },
      rust_analyzer = { enabled = false },
    },
  },
}
