---@type ChadrcConfig
local M = {}

-- Load theme override if it exists
local theme_override = "catppuccin"
local ok, override = pcall(require, "custom.theme-override")
if ok and vim.g.nvchad_theme then
  theme_override = vim.g.nvchad_theme
end

M.ui = {
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
    separator_style = theme_override == "shadcn" and "round" or "block",
  },
  tabufline = {
    enabled = true,
    show_numbers = false,
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

M.lsp = { signature = false }

M.base46 = {
  theme = theme_override,
  hl_override = {
    FoldColumn = {
      bg = "black",
      fg = "purple",
    },
  },
}

return M
