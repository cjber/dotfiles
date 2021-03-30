require'nvim-treesitter.configs'.setup {
    textobjects = {
        select = {
            enable = true,
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner'
            }
        }
    },
    move = {
        enable = true,
        goto_next_start = {
            ['<M-j>'] = '@function.outer',
            ['<M-l>'] = '@class.outer'
        },
        goto_next_end = {
            ['<M-J>'] = '@function.outer',
            ['<M-L>'] = '@class.outer'
        },
        goto_previous_start = {
            ['<M-k>'] = '@function.outer',
            ['<M-h>'] = '@class.outer'
        },
        goto_previous_end = {
            ['<M-K>'] = '@function.outer',
            ['<M-H'] = '@class.outer'
        }
    }
}
