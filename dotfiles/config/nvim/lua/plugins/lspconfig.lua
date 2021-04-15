vim.lsp.handlers['textDocument/publishDiagnostics'] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics,
                 {virtual_text = false, underline = true, signs = true})
vim.cmd [[autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()]]
vim.cmd [[autocmd CursorHoldI * silent! lua vim.lsp.buf.signature_help()]]

-- customise diagnostics
vim.lsp.handlers['textDocument/publishDiagnostics'] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics,
                 {virtual_text = false, signs = true, update_in_insert = false})

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
require'lspconfig'.pyright.setup {}
require'lspconfig'.efm.setup {
    filetypes = {'python', 'markdown', 'yaml', 'json', 'vim', 'lua'}
}
require'lspconfig'.dockerls.setup {}
require'lspconfig'.r_language_server.setup {}
require'lspconfig'.texlab.setup {}
require'lspconfig'.vimls.setup {}
require'lspconfig'.yamlls.setup {}

-- set the path to the sumneko installation; if you previously installed via the now deprecated :LspInstall, use
local sumneko_root_path = '/usr/lib/lua-language-server'
local sumneko_binary = '/usr/bin/lua-language-server'

require'lspconfig'.sumneko_lua.setup {
    cmd = {sumneko_binary, '-E', sumneko_root_path .. '/main.lua'},
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = vim.split(package.path, ';')
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim', 'use'}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
                }
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {enable = false}
        }
    }
}
