vim.lsp.handlers['textDocument/publishDiagnostics'] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics,
                 {virtual_text = false, underline = true, signs = true})
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

require'lspconfig'.efm.setup {
    filetypes = {'python', 'markdown', 'yaml', 'json', 'vim', 'lua'}
}
require'lspconfig'.pyright.setup {}
require'lspconfig'.dockerls.setup {}
require'lspconfig'.r_language_server.setup {}
require'lspconfig'.texlab.setup {}
require'lspconfig'.vimls.setup {}
require'lspconfig'.yamlls.setup {}

local sumneko_root_path = '/usr/lib/lua-language-server'
local sumneko_binary = '/usr/bin/lua-language-server'

require'lspconfig'.sumneko_lua.setup {
    cmd = {sumneko_binary, '-E', sumneko_root_path .. '/main.lua'},
    settings = {
        Lua = {
            runtime = {version = 'LuaJIT', path = vim.split(package.path, ';')},
            diagnostics = {globals = {'vim', 'use'}},
            workspace = {
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
                }
            },
            telemetry = {enable = false}
        }
    }
}
