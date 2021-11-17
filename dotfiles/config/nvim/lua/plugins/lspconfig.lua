local border = {
    {'┌', 'FloatBorder'},
    {'─', 'FloatBorder'},
    {'┐', 'FloatBorder'},
    {'│', 'FloatBorder'},
    {'┘', 'FloatBorder'},
    {'─', 'FloatBorder'},
    {'└', 'FloatBorder'},
    {'│', 'FloatBorder'}
}

local signs = {Error = ' ', Warn = ' ', Hint = ' ', Info = ' '}

for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = ''})
end

-- customise diagnostics
vim.lsp.handlers['textDocument/publishDiagnostics'] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        border = border
    })

vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, {border = border})

vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, {border = border})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

require('lsp_signature').setup({
    bind = true,
    handler_opts = {border = border},
    hint_scheme = 'Comment',
    hint_prefix = ' ',
    -- floating_window = false,
    -- fix_pos = true,
    max_height = 6,
    max_width = 89
})

require'lspconfig'.efm.setup {
    filetypes = {'python', 'markdown', 'yaml', 'json', 'vim', 'lua', 'sql'},
    capabilities = capabilities

}
-- require'lspconfig'.jedi_language_server.setup {}
require'lspconfig'.pyright.setup {
    flags = {debounce_text_changes = 150},
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'openFilesOnly'
            }
        }
    },
    capabilities = capabilities
}

require'lspconfig'.dockerls.setup {capabilities = capabilities}
require'lspconfig'.r_language_server.setup {
    filetypes = {'r', 'rmd'},
    capabilities = capabilities
}
require'lspconfig'.texlab.setup {capabilities = capabilities}
require'lspconfig'.vimls.setup {capabilities = capabilities}
require'lspconfig'.yamlls.setup {capabilities = capabilities}
require'lspconfig'.jsonls.setup {capabilities = capabilities}
require'lspconfig'.rust_analyzer.setup {capabilities = capabilities}
--[[ require'lspconfig'.sqlls.setup {
    capabilities = capabilities,
    cmd = {'/usr/bin/sql-language-server', 'up', '--method', 'stdio'}
} ]]

require'lspconfig'.zeta_note.setup {
    cmd = {'/home/cjber/bin/zeta-note-linux'},
    capabilities = capabilities,
    root_dir = require'lspconfig'.util.root_pattern('.git')
}

local luadev = require('lua-dev').setup({
    lspconfig = {
        cmd = {'lua-language-server'},
        settings = {Lua = {diagnostics = {globals = {'use'}}}}
    },
    capabilities = capabilities

})

require'lspconfig'.sumneko_lua.setup(luadev)

require('grammar-guard').init()
require('lspconfig').grammar_guard.setup({
    capabilities = capabilities,
    filetypes = {'rmd', 'tex', 'markdown'},
    settings = {
        ltex = {
            enabled = {'latex', 'tex', 'bib', 'markdown'},
            language = 'en-GB',
            diagnosticSeverity = 'information',
            setenceCacheSize = 2000,
            additionalRules = {enablePickyRules = false, motherTongue = 'en-GB'},
            trace = {server = 'verbose'},
            dictionary = {},
            disabledRules = {
                ['en-GB'] = {'OXFORD_SPELLING_Z_NOT_S', 'MORFOLOGIK_RULE_EN_GB'}
            },
            hiddenFalsePositives = {}
        }
    }
})

require('sourcery')
require('lspconfig').sourcery.setup {}
require('rust-tools').setup({})
