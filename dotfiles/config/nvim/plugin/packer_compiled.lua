-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/cjber/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?.lua;/home/cjber/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?/init.lua;/home/cjber/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?.lua;/home/cjber/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/cjber/.cache/nvim/packer_hererocks/2.0.5/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["AutoSave.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/AutoSave.nvim"
  },
  NrrwRgn = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/NrrwRgn"
  },
  ["Nvim-R"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/Nvim-R"
  },
  ["alpha-nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/alpha-nvim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/cmp-buffer"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp"
  },
  ["cmp-nvim-lua"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/cmp-nvim-lua"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/cmp-path"
  },
  ["cmp-tabnine"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/cmp-tabnine"
  },
  ["direnv.vim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/direnv.vim"
  },
  ["grammar-guard.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/grammar-guard.nvim"
  },
  ["headlines.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/headlines.nvim"
  },
  ["hotpot.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/hotpot.nvim"
  },
  ["indent-blankline.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim"
  },
  kommentary = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/kommentary"
  },
  ["lightspeed.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/lightspeed.nvim"
  },
  ["lsp-trouble.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/lsp-trouble.nvim"
  },
  ["lspkind-nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/lspkind-nvim"
  },
  ["lspsaga.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/lspsaga.nvim"
  },
  ["lua-dev.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/lua-dev.nvim"
  },
  ["magma-nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/magma-nvim"
  },
  ["numb.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/numb.nvim"
  },
  ["nvim-autopairs"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-autopairs"
  },
  ["nvim-bqf"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-bqf"
  },
  ["nvim-bufferline.lua"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-bufferline.lua"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-cmp"
  },
  ["nvim-colorizer.lua"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua"
  },
  ["nvim-hlslens"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-hlslens"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-lspupdate"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-lspupdate"
  },
  ["nvim-nonicons"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-nonicons"
  },
  ["nvim-notify"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-notify"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textobjects"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  playground = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["project.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/project.nvim"
  },
  ["spellsitter.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/spellsitter.nvim"
  },
  ["startuptime.vim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/startuptime.vim"
  },
  ["symbols-outline.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/symbols-outline.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["todo-comments.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/todo-comments.nvim"
  },
  ["todo.txt-vim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/todo.txt-vim"
  },
  ["tokyonight.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/tokyonight.nvim"
  },
  ["traces.vim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/traces.vim"
  },
  ["vim-dispatch"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/vim-dispatch"
  },
  ["vim-doge"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/vim-doge"
  },
  ["vim-mundo"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/vim-mundo"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/vim-repeat"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/vim-surround"
  },
  ["vim-vsnip"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/vim-vsnip"
  },
  ["vim-vsnip-integ"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/vim-vsnip-integ"
  },
  vimcmdline = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/vimcmdline"
  },
  vimtex = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/vimtex"
  },
  ["which-key.nvim"] = {
    loaded = true,
    path = "/home/cjber/.local/share/nvim/site/pack/packer/start/which-key.nvim"
  }
}

time([[Defining packer_plugins]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
