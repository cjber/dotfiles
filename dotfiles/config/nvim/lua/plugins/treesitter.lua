local ts_config = require('nvim-treesitter.configs')

ts_config.setup {
    pyfold = {enable = true, custom_foldtext = true},
    ensure_installed = 'all',
    highlight = {enable = true, use_languagetree = true},
    indent = {enable = false}, -- sometimes breaks
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm'
        }
    }
}

require'nvim-treesitter.configs'.setup {
    playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?'
        }
    }
}
require'treesitter-context'.setup {
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    throttle = true -- Throttles plugin updates (may improve performance)
}

require'nvim-treesitter.configs'.setup {
    textobjects = {
        move = {
            enable = true,
            lookahead = true,
            keymaps = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner'
            },
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {['<M-j>'] = '@function.outer'},
            goto_previous_start = {['<M-k>'] = '@function.outer'}
        }
    }
}
