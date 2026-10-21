-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set('n', '<leader>gd', function()
  vim.fn.jobstart("tmux new-window -n 'gh-dash' 'gh dash'")
end, { desc = 'Open gh-dash in new tmux window' })
