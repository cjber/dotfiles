return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
    -- Enable syntax highlighting
    highlight = {
      enable = true,
      use_languagetree = true,
      additional_vim_regex_highlighting = false,
    },

    -- Enable indentation
    indent = {
      enable = true,
      -- Disable for Python as it can be unreliable
      disable = { "python" },
    },

    -- Incremental selection
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },

    -- Ensure these parsers are installed
    ensure_installed = {
      -- Languages
      "python",
      "bash",
      "lua",
      "vim",
      "vimdoc",

      -- Data formats
      "json",
      "yaml",
      "toml",
      "markdown",
      "markdown_inline",

      -- Web
      "html",
      "css",
      "javascript",

      -- DevOps
      "dockerfile",
      "sql",

      -- Neovim specific
      "query",
      "regex",
    },

    -- Auto-install missing parsers
    auto_install = true,
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
