return {
  -- Target the specific plugin that sets up the dockerls LSP
  "neovim/nvim-lspconfig",
  -- Key specifies the language server you want to target (dockerls)
  opts = {
    servers = {
      dockerls = {
        enabled = false,
      },
    },
  },
}
