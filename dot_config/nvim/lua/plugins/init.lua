return {
  -- Import plugin configurations from configs/
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

  -- Git integration
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      integrations = {
        telescope = true,
        diffview = true,
      },
    },
  },

  -- Navigation and editing
  {
    "smoka7/hop.nvim",
    event = "VeryLazy",
    opts = { keys = "etovxqpdygfblzhckisuran" },
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    version = "*",
    opts = {},
  },

  -- Buffer management
  {
    "kazhala/close-buffers.nvim",
    cmd = { "BDelete", "BWipeout" },
    opts = {},
  },

  -- Undo tree
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = { { "<leader>fu", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" } },
  },

  -- Documentation generation
  {
    "danymat/neogen",
    cmd = "Neogen",
    keys = { { "<leader>lg", "<cmd>Neogen<cr>", desc = "Generate documentation" } },
    opts = {
      snippet_engine = "luasnip",
      languages = {
        python = { template = { annotation_convention = "google_docstrings" } },
      },
    },
  },

  -- Project management
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = {
      silent_chdir = true,
      detection_methods = { "pattern" },
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
    },
  },

  -- Diagnostics
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    opts = {
      preset = "nonerdfont",
      options = {
        show_source = true,
        throttle = 20,
      },
    },
  },

  -- Trouble - Better diagnostics
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    keys = {
      { "<leader>le", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle diagnostics" },
      { "<leader>ll", "<cmd>Trouble lsp_document_symbols toggle<cr>", desc = "LSP symbols" },
      { "<leader>ld", "<cmd>Trouble lsp_references toggle<cr>", desc = "LSP references" },
      { "<leader>ft", "<cmd>Trouble todo toggle<cr>", desc = "Todo list" },
    },
    opts = {},
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Typing game
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    cmd = { "Typr", "TyprStats" },
    opts = {},
  },

  -- Todo.txt syntax
  {
    "freitass/todo.txt-vim",
    ft = { "todo" },
  },

  -- Disabled plugins
  { "nvim-tree/nvim-tree.lua", enabled = false },
  { "williamboman/mason.nvim", enabled = false },
}
