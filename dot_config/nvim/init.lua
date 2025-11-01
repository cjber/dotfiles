-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

-- Set leader key before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- NvChad base46 theme cache location
vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"

-- Load lazy.nvim configuration
local lazy_config = require "configs.lazy"

-- Setup lazy.nvim with NvChad and custom plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
  { import = "plugins" },
}, lazy_config)

-- Load NvChad theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- Load custom options
require "options"

-- Load NvChad autocmds
require "nvchad.autocmds"

-- Schedule mappings to load after initialization
-- This prevents conflicts during startup
vim.schedule(function()
  require "mappings"
end)
