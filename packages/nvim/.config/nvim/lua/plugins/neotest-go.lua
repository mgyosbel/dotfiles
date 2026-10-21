local config_names = { ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json" }

local function module_root(filename)
  return vim.fs.root(filename, "go.mod") or vim.fs.dirname(filename)
end

local function lint_config(filename)
  return vim.fs.find(config_names, { path = vim.fs.dirname(filename), upward = true, type = "file" })[1]
end

-- Prefer the project's pinned linter over Mason's global installation.
-- Resolve per invocation so switching projects or updating mise.toml takes effect.
local function linter_command(cwd)
  if vim.fn.executable("mise") == 1 then
    local result = vim.system({ "mise", "which", "golangci-lint" }, { cwd = cwd, text = true }):wait(3000)
    local path = vim.trim(result.stdout or "")
    if result.code == 0 and vim.fn.executable(path) == 1 then
      return path
    end
  end
  return vim.fn.exepath("golangci-lint")
end

return {
  { "fredrikaverpil/neotest-golang" },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- nvim-lint owns lint diagnostics and uses the project-pinned binary.
        golangci_lint_ls = { enabled = false },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.go = { "golangcilint" }
      opts.linters.golangcilint = function()
        local filename = vim.api.nvim_buf_get_name(0)
        local cwd = module_root(filename)
        local linter = vim.deepcopy(require("lint.linters.golangcilint"))
        linter.cmd = linter_command(cwd)
        linter.cwd = cwd
        -- Lint the current package from its own module, including nested modules.
        linter.args[#linter.args] = vim.fs.root(filename, "go.mod") and vim.fs.dirname(filename) or filename
        return linter
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft.go = function(bufnr)
        if lint_config(vim.api.nvim_buf_get_name(bufnr)) then
          return { "golangci-lint" }
        end
        return { "goimports", "gofumpt" }
      end
      opts.formatters["golangci-lint"] = {
        command = function(_, ctx)
          return linter_command(module_root(ctx.filename))
        end,
        cwd = function(_, ctx)
          return module_root(ctx.filename)
        end,
        args = function(_, ctx)
          return { "fmt", "--stdin", "--config", lint_config(ctx.filename) }
        end,
      }
    end,
  },
}
