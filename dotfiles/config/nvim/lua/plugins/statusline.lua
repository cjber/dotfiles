local colors = {
    bg = "#1a1b26",
    fg = "#c0caf5",
    fg_dark = "#414868",
    yellow = "#ECBE7B",
    green = "#9ECE6A",
    orange = "#e0af68",
    magenta = "#bb9af7",
    blue = "#3d59a1",
    red = "#f7768e",
}

local tnc = require("tokyonight.colors").setup({})

local bubbles_theme = {
    normal = {
        a = { fg = colors.bg, bg = colors.green },
        b = { fg = tnc.fg_dark, bg = tnc.bg_dark },
        c = { fg = colors.bg, bg = colors.bg },
    },

    insert = { a = { fg = colors.bg, bg = colors.orange } },
    visual = { a = { fg = colors.bg, bg = colors.magenta } },
    replace = { a = { fg = colors.bg, bg = colors.red } },

    inactive = {
        a = { fg = tnc.fg_dark, bg = colors.bg },
        b = { fg = tnc.fg_dark, bg = colors.bg },
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
    local python = vim.trim(vim.fn.system("which python"))
    local version = vim.trim(vim.fn.system("python --version"))

    if string.find(python, ".direnv") ~= nil then
        return "direnv: " .. version
    elseif string.find(python, ".mamba" ~= nil) then
        return "mamba: " .. version
    else
        return "no venv: " .. version
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
            { "branch", icon = { "", color = { fg = tnc.purple } } },
            "diff",
        },
        lualine_c = {
            {
                venv,
                cond = function()
                    return vim.fn.expand(vim.bo.filetype) == "python"
                end,
                icon = " ",
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
                icon = { " ", color = { fg = tnc.yellow } },
                color = { fg = tnc.fg_dark, gui = "bold" },
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
