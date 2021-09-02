-- customise diagnostics
vim.lsp.handlers['textDocument/publishDiagnostics'] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics,
                 {virtual_text = false, signs = true, update_in_insert = false})

vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, {border = 'single'})

vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signature_help, {border = 'single'})

-- python organize imports
function OrganizeImports(bufnr)
    local uri = vim.uri_from_bufnr(bufnr)
    local params = {command = 'pyright.organizeimports', arguments = {uri}}

    local edits = vim.lsp.buf_request(bufnr, 'workspace/executeCommand', params,
                                      function(err, _, _)
        if err then error(tostring(err)) end
    end)

    if edits then vim.lsp.util.apply_workspace_edit(edits) end
end

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

local luadev = require('lua-dev').setup({
    lspconfig = {cmd = {'lua-language-server'}},
    capabilities = capabilities
})

require'lspconfig'.sumneko_lua.setup(luadev)

require('grammar-guard').init()
require('lspconfig').grammar_guard.setup({
    filetypes = {'rmd', 'tex', 'markdown'},
    settings = {
        ltex = {
            enabled = {'latex', 'tex', 'bib', 'markdown'},
            language = 'en-GB',
            diagnosticSeverity = 'information',
            setenceCacheSize = 2000,
            additionalRules = {enablePickyRules = true, motherTongue = 'en-GB'},
            trace = {server = 'verbose'},
            dictionary = {},
            disabledRules = {['en-GB'] = {'OXFORD_SPELLING_Z_NOT_S'}},
            hiddenFalsePositives = {}
        }
    }
})
