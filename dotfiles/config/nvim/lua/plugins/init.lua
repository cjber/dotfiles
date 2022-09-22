require("plugins.plugs") -- load plugins
require("plugins.statusline")
require("plugins.treesitter") -- syntax
require("plugins.telescope") -- interactive search

require('tokyonight').setup({ style = 'night' })

require('nvim-tree').setup()
require('crates').setup()
require("todo-comments").setup()
require("close_buffers").setup()
require("mason").setup()
require("mason-tool-installer").setup({
    ensure_installed = {
        'black',
        'flake8',
        'pyright',
        'jedi-language-server',
        'vale',
        'dockerfile-language-server',
        'r-languageserver',
        'sourcery'
    }
})

-- lsp configs
require("project_nvim").setup({ silent_chdir = true })
require("plugins.langconfig") -- lsp config
require("plugins.cmp") -- lsp config

local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = ("  %d "):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, "Comment" })
    return newVirtText
end

require("indent_blankline").setup({ show_current_context = true, show_current_context_start = false,
    char = '▎' })

require('leap').setup({
    case_sensitive = false
})
require('leap').set_default_keymaps()

-- global handler
require("ufo").setup({
    fold_virt_text_handler = handler,
    preview = { win_config = { border = "single" } },
})

-- buffer scope handler
-- will override global handler if it is existed
local bufnr = vim.api.nvim_get_current_buf()
require("ufo").setFoldVirtTextHandler(bufnr, handler)

-- misc
require("nvim-surround").setup()
require("nvim-autopairs").setup({})
require("fidget").setup({ text = {
    spinner = "dots",
} }) -- show lsp progress

require("trouble").setup() -- diagnostic results window etc
require("Comment").setup()
require("colorizer").setup({ "*" }, { mode = "foreground" })
require("which-key").setup()
require("auto-save").setup()

-- vim.fn.sign_define("Headline1", { linehl = "Headline1" })
-- vim.fn.sign_define("Headline2", { linehl = "Headline2" })

require("headlines").setup({
    quarto = {
        query = vim.treesitter.parse_query(
            "markdown",
            [[
                (atx_heading [
                    (atx_h1_marker)
                    (atx_h2_marker)
                    (atx_h3_marker)
                    (atx_h4_marker)
                    (atx_h5_marker)
                    (atx_h6_marker)
                ] @headline)
                (thematic_break) @dash
                (fenced_code_block) @codeblock
                (block_quote_marker) @quote
                (block_quote (paragraph (inline (block_continuation) @quote)))
            ]]
        ),
        treesitter_language = "markdown",
        headline_highlights = { "Headline" },
        codeblock_highlight = "CodeBlock",
        dash_highlight = "Dash",
        dash_string = "-",
        quote_highlight = "Quote",
        quote_string = "┃",
        fat_headlines = false,
        fat_headline_upper_string = "▃",
        fat_headline_lower_string = "🬂",
    },
    markdown = { fat_headlines = false }
})

-- custom notification for square border
local stages_util = require("notify.stages.util")
require("notify").setup({
    timeout = 200,
    stages = {
        function(state)
            local next_height = state.message.height + 2
            local next_row = stages_util.available_row(state.open_windows, next_height)
            if not next_row then
                return nil
            end
            return {
                relative = "editor",
                anchor = "NE",
                width = state.message.width,
                height = state.message.height,
                col = vim.opt.columns:get(),
                row = next_row,
                border = "single",
                style = "minimal",
                opacity = 0,
            }
        end,
        function()
            return { opacity = { 100 }, col = { vim.opt.columns:get() } }
        end,
        function()
            return { col = { vim.opt.columns:get() }, time = true }
        end,
        function()
            return {
                opacity = {
                    0,
                    frequency = 2,
                    complete = function(cur_opacity)
                        return cur_opacity <= 4
                    end,
                },
                col = { vim.opt.columns:get() },
            }
        end,
    },
})

require("neogen").setup() -- add docstrings

require("scrollbar.handlers.search").setup()
local colors = require("tokyonight.colors").setup()
require("scrollbar").setup({
    handlers = { diagnostic = true, search = true },
    handle = { color = colors.bg_highlight },
    marks = {
        Search = { color = colors.orange },
        Error = { color = colors.error },
        Warn = { color = colors.warning },
        Info = { color = colors.info },
        Hint = { color = colors.hint },
        Misc = { color = colors.purple },
    },
})
local get_hex = require("cokeline/utils").get_hex

require("cokeline").setup({
    default_hl = {
        fg = function(buffer)
            return buffer.is_focused and get_hex("Normal", "fg") or get_hex("Comment", "fg")
        end,
        bg = colors.bg_dark,
    },

    components = {
        {
            text = " ",
            bg = get_hex("Normal", "bg"),
        },
        {
            text = "",
            fg = colors.bg_dark,
            bg = get_hex("Normal", "bg"),
        },
        {
            text = function(buffer)
                return buffer.devicon.icon
            end,
            fg = function(buffer)
                return buffer.devicon.color
            end,
        },
        {
            text = " ",
        },
        {
            text = function(buffer)
                return buffer.filename .. "  "
            end,
            style = function(buffer)
                return buffer.is_focused and "bold" or nil
            end,
        },
        {
            text = "",
            fg = colors.bg_dark,
            bg = get_hex("Normal", "bg"),
        },
    },
})
