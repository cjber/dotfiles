return {
  -- Imports from configs
  { import = "configs.cmp" },
  { import = "configs.gitsigns" },
  { import = "configs.copilot" },
  { import = "configs.peek" },
  { import = "configs.notify" },
  { import = "configs.treesitter" },
  { import = "configs.treesitter-textobjects" },
  { import = "configs.lint" },
  { import = "configs.conform" },
  { import = "configs.yarepl" },
  { import = "configs.lazydev" },
  { import = "configs.statuscol" },
  { import = "configs.autosave" },
  { import = "configs.oil" },
  { import = "configs.telescope" },
  { import = "configs.lspconfig" },

  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
      "ibhagwan/fzf-lua",
      "echasnovski/mini.pick",
    },
    config = true,
  },

  { "smoka7/hop.nvim", event = "VeryLazy", config = true },
  { "kylechui/nvim-surround", event = "VeryLazy", config = true },
  { "kazhala/close-buffers.nvim", event = "VeryLazy", config = true },
  { "mbbill/undotree", cmd = "UndotreeToggle" },
  { "danymat/neogen", config = true },

  {
    "ahmedkhalf/project.nvim",
    lazy = false,
    config = function()
      require("project_nvim").setup { silent_chdir = true, detection_methods = { "pattern" } }
    end,
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup { preset = "nonerdfont" }
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle", "TodoTrouble" },
    opts = {},
  },
  { "folke/todo-comments.nvim", opts = {} },

  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },

  { "freitass/todo.txt-vim", lazy = false },

  -- Disabled Plugins
  { "nvim-tree/nvim-tree.lua", enabled = false },
  { "williamboman/mason.nvim", enabled = false },
}
