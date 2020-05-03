nnoremap <leader>lc :Semshi rename<CR>

function s:pandas_view()
    python import pandas;<cword>.head(50).to_csv('/tmp/_'+<cword>+'.csv')
    nvim /tmp/_<cword>.csv
