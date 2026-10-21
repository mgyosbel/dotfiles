-- Diagnostics backend used for Rust: "rust-analyzer" or "bacon-ls".
-- Configured in `lua/config/options.lua` via `vim.g.lazyvim_rust_diagnostics`.
local diagnostics = vim.g.lazyvim_rust_diagnostics or "rust-analyzer"

return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    optional = true,
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "tflint",
        -- rust dependencies
        "rust-analyzer",
        "codelldb",
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      local ensure_installed = opts.ensure_installed or {}
      -- mason.nvim v2 dropped `ensure_installed` as a setting, so the list is
      -- installed manually from the registry below.
      opts.ensure_installed = nil

      if diagnostics == "bacon-ls" then
        vim.list_extend(ensure_installed, { "bacon", "bacon-ls" })
      end

      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(vim.fn.uniq(ensure_installed)) do
          if not mr.has_package(tool) then
            vim.notify(("[mason] unknown package: %s"):format(tool), vim.log.levels.WARN)
          else
            local p = mr.get_package(tool)
            if not p:is_installed() then
              p:install()
            end
          end
        end
      end)
    end,
  },
}
