return {
  "nvim-telescope/telescope.nvim",
  optional = true,
  specs = {
    {
      "ANGkeith/telescope-terraform-doc.nvim",
      ft = { "terraform", "hcl" },
      config = function()
        LazyVim.on_load("telescope.nvim", function()
          require("telescope").load_extension("terraform_doc")
        end)
      end,
    },
    {
      "cappyzawa/telescope-terraform.nvim",
      ft = { "terraform", "hcl" },
      config = function()
        LazyVim.on_load("telescope.nvim", function()
          require("telescope").load_extension("terraform")
        end)
      end,
    },
  },
}
