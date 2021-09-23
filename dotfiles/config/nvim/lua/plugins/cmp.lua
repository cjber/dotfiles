local cmp = require('cmp')
cmp.setup {
    -- experimental = {ghost_text = true},
    snippet = {expand = function(args) vim.fn['vsnip#anonymous'](args.body) end},
    mapping = {
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true
        })
    },

    -- You should specify your *installed* sources.
    sources = {
        {name = 'nvim_lsp'},
        {name = 'nvim_lua'},
        {name = 'cmp_tabnine'},
        {name = 'buffer'},
        {name = 'path'},
        {name = 'crates'}

    },
    formatting = {
        format = function(entry, vim_item)
            vim_item.kind = require('lspkind').presets.default[vim_item.kind] ..
                                ' ' .. vim_item.kind
            vim_item.menu = ({
                buffer = '[Buffer]',
                nvim_lsp = '[LSP]',
                luasnip = '[LuaSnip]',
                nvim_lua = '[Lua]',
                latex_symbols = '[Latex]',
                cmp_tabnine = '[TN]'
            })[entry.source.name]
            return vim_item
        end
    },
    documentation = {
        border = {'┌', '─', '┐', '│', '┘', '─', '└', '│'}
    }
}
require('cmp_tabnine.config'):setup({
    max_lines = 1000,
    max_num_results = 20,
    sort = true,
    show_prediction_strength = true
})

require('nvim-autopairs').setup {}
require('nvim-autopairs.completion.cmp').setup({
    map_cr = true, --  map <CR> on insert mode
    map_complete = true, -- it will auto insert `(` (map_char) after select function or method item
    auto_select = true, -- automatically select the first item
    insert = false, -- use insert confirm behavior instead of replace
    map_char = { -- modifies the function or method delimiter by filetypes
        all = '(',
        tex = '{'
    }
})
