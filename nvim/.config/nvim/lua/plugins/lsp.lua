return {
  "neovim/nvim-lspconfig",
  opts = {
      inlay_hints = {
        enabled = false,
        exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
      },
    }
}
