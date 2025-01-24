return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "python", "sql" } } },
  {
    "hrsh7th/nvim-cmp",
    opts = {
      sources = {
        { name = "nvim_lsp_signature_help" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "nvim_lua" },
        { name = "path" },
      },
    },
  },

  { "nvim-telescope/telescope.nvim", opts = {
    pickers = { find_files = { follow = true } },
  } },

  -- extra plugins
  { "smoka7/hop.nvim", event = "VeryLazy", opts = {} },
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
  { "kazhala/close-buffers.nvim", event = "VeryLazy", opts = {} },

  {
    "ahmedkhalf/project.nvim",
    lazy = false,
    config = function()
      require("project_nvim").setup { silent_chdir = true, detection_methods = { "pattern" } }
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle", "TodoTrouble" },
    opts = {},
  },
  { "folke/todo-comments.nvim", opts = {} },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup { preset = "nonerdfont" }
    end,
  },
  { "stevearc/conform.nvim", opts = require "configs.conform" },

  -- imports
  { import = "configs.lint" },
  { import = "configs.yarepl" },
  { import = "configs.lazydev" },
  { import = "configs.statuscol" },
  { import = "configs.autosave" },
  { import = "configs.codecompanion" },

  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },

  { "freitass/todo.txt-vim", lazy = false },
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
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
  },
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
          vim.api.nvim_win_set_config(win, { border = "single" })
        end,
      }
    end,
  },

  -- disabled
  { "nvim-tree/nvim-tree.lua", enabled = false },
  { "williamboman/mason.nvim", enabled = false },
}
