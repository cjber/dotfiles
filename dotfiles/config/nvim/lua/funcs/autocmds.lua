local M = {}

-- TODO update when api supports
M.define_autocmds = function(autocmds)
    for event, event_cmds in pairs(autocmds) do
        for pattern, pattern_cmds in pairs(event_cmds) do
            for _, cmd in ipairs(pattern_cmds) do
                vim.cmd('autocmd ' .. event .. ' ' .. pattern .. ' ' .. cmd)
            end
        end
    end
end

M.my_fd = function(opts)
    opts = opts or {}
    opts.cwd = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
    if vim.v.shell_error ~= 0 then
        opts.cwd = vim.lsp.get_active_clients()[1].config.root_dir
    end
    require'telescope.builtin'.find_files(opts)
end

return M
