local ts_config = require('nvim-treesitter.configs')

ts_config.setup {
    ensure_installed = 'all',
    highlight = {enable = true}
    -- indent = {enable = true}, -- sometimes breaks
    -- incremental_selection = {enable = true}
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
