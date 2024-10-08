---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "catppuccin",
  lsp_semantic_tokens = true,

  cmp = {
    icons = true,
    lspkind_text = false,
    style = "flat_dark",
    selected_item_bg = "simple",
  },

  telescope = { style = "borderless" },

  statusline = {
    theme = "minimal",
    separator_style = "block",
  },
  tabufline = {
    show_numbers = false,
    enabled = true,
    lazyload = true,
    overriden_modules = function(modules)
      table.remove(modules, 4)
    end,
  },

  nvdash = {
    load_on_startup = false,
    buttons = {
      { "  Find File", "Spc f f", "Telescope find_files" },
      { "󰈚  Recent Files", "Spc f o", "Telescope oldfiles" },
      { "󰈭  Find Word", "Spc f w", "Telescope live_grep" },
      { "  Bookmarks", "Spc m a", "Telescope marks" },
    },
  },
}

-- test
M.base46 = {
  hl_override = {
    FoldColumn = {
      bg = "black",
      fg = "purple",
    },
  },
}

return M
