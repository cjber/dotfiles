local ts_config = require("nvim-treesitter.configs")

ts_config.setup({
    ensure_installed = { "python", "markdown", "markdown_inline", "sql", "yaml", "r", "lua", "vim", "query", "help" },
    highlight = { enable = true, use_languagetree = true, additional_vim_regex_highlighting = false },
    indent = { enable = true }, -- sometimes breaks
    incremental_selection = {
        enable = false,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = { ["<M-j>"] = "@function.outer" },
            goto_previous_start = { ["<M-k>"] = "@function.outer" },
        },
    },
    yati = { enable = true },
})
