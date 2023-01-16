local colors = require("tokyonight.colors").setup()

local bubbles_theme = {
	normal = {
		a = { fg = colors.bg, bg = colors.green },
		b = { fg = colors.fg_dark, bg = colors.bg_dark },
		c = { fg = colors.bg, bg = colors.none },
	},

	insert = { a = { fg = colors.bg, bg = colors.orange } },
	visual = { a = { fg = colors.bg, bg = colors.magenta } },
	replace = { a = { fg = colors.bg, bg = colors.red } },

	inactive = {
		a = { fg = colors.fg_dark, bg = colors.bg },
		b = { fg = colors.fg_dark, bg = colors.bg },
		c = { fg = colors.bg, bg = colors.bg },
	},
}

local function lsp()
	local msg = "None"
	local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
	local clients = vim.lsp.get_active_clients()
	if next(clients) == nil then
		return msg
	end
	for _, client in ipairs(clients) do
		local filetypes = client.config.filetypes
		if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
			return client.name
		end
	end
	return msg
end

local function venv()
	if os.getenv("VIRTUAL_ENV") then
		return "(" .. os.getenv("VIRTUAL_ENV"):match("^.+/(.+)$") .. ")"
    else
        return ""
	end
end

require("lualine").setup({
	options = {
		theme = bubbles_theme,
		global_statusline = true,
		component_separators = "::",
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = {
			{
				"mode",
				separator = { left = "" },
				right_padding = 2,
				fmt = function(res)
					return res:sub(1, 6)
				end,
			},
		},
		lualine_b = {
			{ "filename", symbols = { modified = "  ", readonly = "  " } },
			{ "branch", icon = { "", color = { fg = colors.purple } } },
			"diff",
		},
		lualine_c = {
			{
				venv,
				icon = "",
				color = { fg = colors.green, gui = "bold" },
			},
		},
		lualine_x = {
			{
				"diagnostics",
				sources = { "nvim_diagnostic", "coc" },
				sections = { "error", "warn", "info", "hint" },
				symbols = { error = " ", warn = " ", info = " ", hint = " " },
				colored = true, -- Displays diagnostics status in color if set to true.
				update_in_insert = false, -- Update diagnostics in insert mode.
				always_visible = false, -- Show diagnostics even if there are none.},
			},
		},
		lualine_y = {
			{
				lsp,
				icon = { " ", color = { fg = colors.yellow } },
				color = { fg = colors.fg_dark, gui = "bold" },
			},
			"filetype",
			"progress",
		},
		lualine_z = {
			{ "location", separator = { right = "" }, left_padding = 2 },
		},
	},
	inactive_sections = {
		lualine_a = { "filename" },
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = { "location" },
	},
	tabline = {},
	extensions = {},
})
