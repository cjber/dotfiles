return {
  -- LSP and Completion
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    opts = {
      sources = {
        { name = "nvim_lsp_signature_help" },
        { name = "nvim_lsp" },
        { name = "codeium" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "nvim_lua" },
        { name = "path" },
      },
    },
  },

  -- File Navigation
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-telescope/telescope-file-browser.nvim" },

    opts = {
      pickers = { find_files = { follow = true } },
    },
  },
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      columns = { "icon", "permissions", "size", "mtime" },
      delete_to_trash = true,
      keymaps_help = { border = "single" },
      view_options = { show_hidden = true },
    },
  },

  -- Git Integration
  {
    "lewis6991/gitsigns.nvim",
    enabled = true,
    opts = {
      signcolumn = true,
      current_line_blame = true,
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "│" },
        topdelete = { text = "┆" },
        changedelete = { text = "┆" },
        untracked = { text = "┆" },
      },
      signs_staged_enable = false,
    },
  },
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

  -- Code Navigation and Editing
  { "smoka7/hop.nvim", event = "VeryLazy", config = true },
  { "kylechui/nvim-surround", event = "VeryLazy", config = true },
  { "kazhala/close-buffers.nvim", event = "VeryLazy", config = true },
  { "mbbill/undotree", cmd = "UndotreeToggle" },
  { "danymat/neogen", config = true },

  -- Project Management
  {
    "ahmedkhalf/project.nvim",
    lazy = false,
    config = function()
      require("project_nvim").setup { silent_chdir = true, detection_methods = { "pattern" } }
    end,
  },

  -- Diagnostics and Troubleshooting
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

  -- AI and Productivity
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup { suggestion = { auto_trigger = true } }
    end,
  },
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },

  -- UI and Visuals
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      vim.notify = require "notify"
      require("notify").setup {
        stages = "fade",
        render = "wrapped-compact",
        timeout = 200,
        merge_duplicates = true,
        on_open = function(win)
          vim.api.nvim_win_set_config(win, { border = "none" })
        end,
      }
    end,
  },
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    filetype = { "markdown" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },

  -- Formatting and Linting
  { "stevearc/conform.nvim", opts = require "configs.conform" },

  -- Imports from configs
  { import = "configs.treesitter" },
  { import = "configs.treesitter-textobjects" },
  { import = "configs.lint" },
  { import = "configs.yarepl" },
  { import = "configs.lazydev" },
  { import = "configs.statuscol" },
  { import = "configs.autosave" },
  { import = "configs.avante" },
  { import = "configs.mcphub" },
  -- { import = "configs.codecompanion" },

  -- Miscellaneous
  { "freitass/todo.txt-vim", lazy = false },

  -- Disabled Plugins
  { "nvim-tree/nvim-tree.lua", enabled = false },
  { "williamboman/mason.nvim", enabled = false },
}
