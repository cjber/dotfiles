-- customise diagnostics
vim.lsp.handlers['textDocument/publishDiagnostics'] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics,
                 {virtual_text = false, signs = true, update_in_insert = false})

vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, {border = 'single'})

vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, {border = 'single'})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

require'lspconfig'.efm.setup {
    filetypes = {'python', 'markdown', 'yaml', 'json', 'vim', 'lua'},
    capabilities = capabilities
}
require'lspconfig'.pyright.setup {
    flags = {debounce_text_changes = 150},
    settings = {
        python = {
            analysis = {
                autoSearchPaths = false,
                useLibraryCodeForTypes = false,
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
require'lspconfig'.sqls.setup {capabilities = capabilities}

require'lspconfig'.zeta_note.setup {
    cmd = {'/home/cjber/bin/zeta-note-linux'},
    capabilities = capabilities,
    root_dir = require'lspconfig'.util.root_pattern('.git')
}

local luadev = require('lua-dev').setup({
    lspconfig = {cmd = {'lua-language-server'}},
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
            disabledRules = {['en-GB'] = {'OXFORD_SPELLING_Z_NOT_S'}},
            hiddenFalsePositives = {}
        }
    }
})

require('sourcery')
require('lspconfig').sourcery.setup {}
