-- vim.cmd [[imap <silent><script><expr> <C-L> copilot#Accept()]]
-- vim.cmd [[let g:copilot_no_tab_map = v:true]]

local cmp = require('cmp')
cmp.setup {
    experimental = {ghost_text = true, custom_menu = true},
    snippet = {expand = function(args) vim.fn['vsnip#anonymous'](args.body) end},
    mapping = {
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = false
        })
    },
    sources = {
        {name = 'nvim_lsp'},
        {name = 'nvim_lua'},
        {name = 'cmp_tabnine'},
        {name = 'vsnip'},
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
                nvim_lua = '[Lua]',
                latex_symbols = '[Latex]',
                cmp_tabnine = '[TN]'
            })[entry.source.name]
            return vim_item
        end
    },
    documentation = {
        border = {'┌', '─', '┐', '│', '┘', '─', '└', '│'},
        winhighlight = 'NormalFloat:NormalFloat,Title:NormalFloat'
    },
    sorting = {
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            require'cmp-under-comparator'.under,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order
        }
    }
}

require('cmp_tabnine.config'):setup({
    max_lines = 1000,
    max_num_results = 20,
    sort = true,
    show_prediction_strength = true
})

require('nvim-autopairs').setup {}
cmp.event:on('confirm_done',
             require('nvim-autopairs.completion.cmp').on_confirm_done())
