return {
  -- Core
  { import = "configs.snacks" },
  { import = "configs.lualine" },
  { import = "configs.blink" },

  -- LSP
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- Code quality
  { import = "configs.conform" },
  { import = "configs.lint" },
  { import = "configs.treesitter" },
  { import = "configs.treesitter-textobjects" },

  -- Git
  { import = "configs.gitsigns" },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    config = true,
  },

  -- Navigation
  { "smoka7/hop.nvim", event = "VeryLazy", config = true },

  -- File management
  { import = "configs.oil" },

  -- Text editing
  { "kylechui/nvim-surround", event = "VeryLazy", config = true },
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  { "kazhala/close-buffers.nvim", event = "VeryLazy", config = true },

  -- UI
  { "folke/which-key.nvim", event = "VeryLazy", config = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({ preset = "nonerdfont" })
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle", "TodoTrouble" },
    opts = {},
  },
  { "folke/todo-comments.nvim", event = "VeryLazy", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },

  -- Project management
  {
    "ahmedkhalf/project.nvim",
    lazy = false,
    config = function()
      require("project_nvim").setup({ silent_chdir = true, detection_methods = { "pattern" } })
    end,
  },

  -- AI
  { import = "configs.avante" },
  { import = "configs.codecompanion" },
  { import = "configs.mcphub" },
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

  -- REPL
  { import = "configs.yarepl" },

  -- Utilities
  { import = "configs.autosave" },
  { import = "configs.peek" },
  { "mbbill/undotree", cmd = "UndotreeToggle" },
  { "danymat/neogen", config = true },
  { "freitass/todo.txt-vim", lazy = false },
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },
}
