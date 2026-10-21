-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)

--- Disable autoformat for lua files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "yaml" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- Force transparent background on all windows (including sidebars/explorers)
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local groups = {
      "Normal", "NormalNC", "NormalFloat", "NormalSB",
      "SignColumn", "EndOfBuffer", "WinSeparator",
      "SnacksPickerList", "SnacksPickerPreview",
      "SnacksExplorerNormal",
    }
    for _, group in ipairs(groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE" })
    end
  end,
})
