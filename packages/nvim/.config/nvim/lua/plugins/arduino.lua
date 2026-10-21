local function sketch_root()
  local root = vim.fs.root(0, "sketch.yaml")
  if not root then
    vim.notify("Add sketch.yaml beside your .ino file with default_fqbn and default_port first.", vim.log.levels.WARN)
  end
  return root
end

local building = false
local function build(upload)
  local root = sketch_root()
  if not root then
    return
  end
  if building then
    vim.notify("An Arduino build is already running.", vim.log.levels.WARN)
    return
  end
  vim.cmd.update()
  local cmd = { "arduino-cli", "compile", "--no-color" }
  if upload then
    table.insert(cmd, "--upload")
  end
  table.insert(cmd, root)
  local title = upload and "Arduino build/upload" or "Arduino build"
  building = true
  vim.notify(title .. " started")
  vim.system(
    cmd,
    { cwd = root, text = true },
    vim.schedule_wrap(function(result)
      building = false
      local output = (result.stdout or "") .. "\n" .. (result.stderr or "")
      vim.fn.setqflist({}, "r", {
        title = title,
        lines = vim.split(output, "\n", { trimempty = true }),
        efm = "%f:%l:%c: %t%*[^:]: %m,%f:%l: %t%*[^:]: %m,%-G%.%#",
      })
      if result.code == 0 then
        vim.notify(title .. " succeeded\n" .. output)
      else
        vim.notify(title .. " failed\n" .. output, vim.log.levels.ERROR)
        vim.cmd.copen()
      end
    end)
  )
end

local function monitor()
  local root = sketch_root()
  if root then
    Snacks.terminal({ "arduino-cli", "monitor" }, { cwd = root })
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local cli_config = vim.fn.has("mac") == 1 and "~/Library/Arduino15/arduino-cli.yaml"
        or "~/.arduino15/arduino-cli.yaml"
      opts.servers.arduino_language_server = {
        root_dir = function(bufnr, on_dir)
          local root = vim.fs.root(bufnr, "sketch.yaml")
          if root then
            on_dir(root)
          end
        end,
        cmd = {
          "arduino-language-server",
          "-cli",
          "arduino-cli",
          "-cli-config",
          vim.fn.expand(cli_config),
          "-clangd",
          vim.fn.exepath("clangd"),
        },
      }
    end,
    keys = {
      {
        "<leader>ab",
        function()
          build(false)
        end,
        desc = "Arduino Build",
      },
      {
        "<leader>au",
        function()
          build(true)
        end,
        desc = "Arduino Build and Upload",
      },
      { "<leader>am", monitor, desc = "Arduino Serial Monitor" },
      {
        "<leader>al",
        function()
          Snacks.terminal({ "arduino-cli", "board", "list" }, { auto_close = false })
        end,
        desc = "Arduino List Connected Boards",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>a", group = "arduino" } } },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "arduino-language-server", "clangd", "clang-format" } },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        arduino = { "clang_format" },
        c = { "clang_format" },
        cpp = { "clang_format" },
      },
    },
  },
}
