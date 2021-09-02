local cmp = require('cmp')
cmp.setup {
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
        {name = 'buffer'},
        {name = 'path'}
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
                latex_symbols = '[Latex]'
            })[entry.source.name]
            return vim_item
        end
    },
    documentation = {
        border = {'┌', '─', '┐', '│', '┘', '─', '└', '│'}
    }
}

require('nvim-autopairs').setup {}
require('nvim-autopairs.completion.cmp').setup({
    map_cr = true, --  map <CR> on insert mode
    map_complete = true, -- it will auto insert `(` after select function or method item
    auto_select = false -- automatically select the first item
})
