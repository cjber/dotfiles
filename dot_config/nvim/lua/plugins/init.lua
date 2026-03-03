return {

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Imports from configs
  { import = "configs.cmp" },
  { import = "configs.gitsigns" },
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

  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        split_side = "right",
        split_width_percentage = 0.30,
        snacks_win_opts = {
          position = "bottom",
          height = 0.30,
        },
      },
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    },
  },

  -- Disabled Plugins
  { "nvim-tree/nvim-tree.lua", enabled = false },
  -- { "williamboman/mason.nvim", enabled = false },
}
