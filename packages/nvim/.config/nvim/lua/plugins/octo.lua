return {
  "pwntester/octo.nvim",
  cmd = { "Octo", "OctoCreatePR" },
  opts = {
    -- or "fzf-lua" or "snacks" or "default"
    picker = "telescope",
    -- bare Octo command opens picker of commands
    enable_builtin = true,
  },
  keys = {
    {
      "<leader>oo",
      "<CMD>Octo<CR>",
      desc = "List Octo commands",
    },
    {
      "<leader>oii",
      "<CMD>Octo<CR>issue ",
      desc = "GitHub Issues Commands",
    },
    {
      "<leader>oil",
      "<CMD>Octo issue list<CR>",
      desc = "List GitHub Issues",
    },
    {
      "<leader>opp",
      "<CMD>Octo<CR>pr ",
      desc = "GitHub PullRequests Commands",
    },
    {
      "<leader>opl",
      "<CMD>Octo pr list<CR>",
      desc = "List GitHub PullRequests",
    },
    {
      "<leader>opc",
      "<CMD>OctoCreatePR<CR>",
      desc = "Create PR (DF)",
    },
    {
      "<leader>od",
      "<CMD>Octo discussion list<CR>",
      desc = "List GitHub Discussions",
    },
    {
      "<leader>on",
      "<CMD>Octo notification list<CR>",
      desc = "List GitHub Notifications",
    },
    {
      "<leader>os",
      function()
        require("octo.utils").create_base_search_command { include_current_repo = true }
      end,
      desc = "Search GitHub",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    -- OR "ibhagwan/fzf-lua",
    -- OR "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function(_, opts)
    require("octo").setup(opts)

    -- DF custom PR creation wrapper.
    -- To enable the template picker, comment out the default line
    -- and uncomment the picker block below.
    local function df_create_pr()
      -- DEFAULT: stock octo behavior
      -- require("octo.commands").create_pr()

      -- TEMPLATE PICKER (uncomment to activate):
      local template_dir = vim.fn.getcwd() .. "/.github/PULL_REQUEST_TEMPLATE"
      local files = vim.fn.glob(template_dir .. "/*.md", false, true)
      if #files == 0 then
        require("octo.commands").create_pr()
        return
      end
      local choices = {}
      for _, f in ipairs(files) do
        table.insert(choices, vim.fn.fnamemodify(f, ":t:r"))
      end
      table.insert(choices, "No template")
      vim.ui.select(choices, { prompt = "Select PR template: " }, function(choice, idx)
        if not choice then return end
        local utils = require("octo.utils")
        local orig = utils.get_repo_templates
        utils.get_repo_templates = function(repo)
          local t = vim.deepcopy(orig(repo))
          if not t then return t end
          if choice == "No template" then
            t.pullRequestTemplates = {}
          else
            local body = table.concat(vim.fn.readfile(files[idx]), "\n")
            t.pullRequestTemplates = { { body = body, filename = files[idx] } }
          end
          utils.get_repo_templates = orig
          return t
        end
        vim.schedule(function()
          require("octo.commands").create_pr()
        end)
      end)
    end

    vim.api.nvim_create_user_command("OctoCreatePR", df_create_pr, {})
  end,
}
