local M = {}

-- Custom LSP rename handler that properly handles annotated text edits
local function custom_rename_handler(err, result, ctx, config)
  if err then
    vim.notify("Rename failed: " .. err.message, vim.log.levels.ERROR)
    return
  end
  
  if not result then
    vim.notify("No rename result received", vim.log.levels.WARN)
    return
  end
  
  -- Get the client to determine offset encoding
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client then
    vim.notify("LSP client not found", vim.log.levels.ERROR)
    return
  end
  
  -- Handle annotated text edits by providing required change_annotations
  if result.documentChanges then
    for _, change in ipairs(result.documentChanges) do
      if change.edits then
        for _, edit in ipairs(change.edits) do
          if edit.annotationId then
            -- Ensure we have change_annotations
            result.changeAnnotations = result.changeAnnotations or {}
            if not result.changeAnnotations[edit.annotationId] then
              result.changeAnnotations[edit.annotationId] = {
                label = "Rename",
                needsConfirmation = false,
                description = "Renamed symbol"
              }
            end
          end
        end
      end
    end
  end
  
  -- Apply the workspace edit with proper offset encoding
  vim.lsp.util.apply_workspace_edit(result, client.offset_encoding or "utf-16")
end

-- Simple rename with input dialog
function M.rename()
  local current_word = vim.fn.expand("<cword>")
  
  vim.ui.input({
    prompt = "Rename to: ",
    default = current_word,
  }, function(new_name)
    if new_name and #new_name > 0 and new_name ~= current_word then
      local params = vim.lsp.util.make_position_params()
      params.newName = new_name
      
      vim.lsp.buf_request(0, "textDocument/rename", params, custom_rename_handler)
    end
  end)
end

-- Fancy rename with floating window
function M.rename_fancy()
  local api = vim.api
  local current_word = vim.fn.expand("<cword>")
  
  -- Check if any LSP client supports rename
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local rename_capable = false
  
  for _, client in ipairs(clients) do
    if client.server_capabilities.renameProvider then
      rename_capable = true
      break
    end
  end
  
  if not rename_capable then
    vim.notify("No LSP client supports rename", vim.log.levels.WARN)
    return
  end
  
  -- Create floating window
  local buf = api.nvim_create_buf(false, true)
  
  local win_opts = {
    relative = "cursor",
    row = 1,
    col = 1,
    width = math.max(#current_word + 15, 30),
    height = 1,
    style = "minimal",
    border = "rounded",
    title = " Rename ",
    title_pos = "center",
  }
  
  local win = api.nvim_open_win(buf, true, win_opts)
  
  -- Set initial text
  api.nvim_buf_set_lines(buf, 0, -1, false, { current_word })
  
  -- Position cursor at end of word
  api.nvim_win_set_cursor(win, { 1, #current_word })
  
  -- Start insert mode
  vim.cmd("startinsert!")
  
  -- Set up keymaps
  local opts = { buffer = buf, silent = true }
  
  -- Escape to cancel
  vim.keymap.set({ "i", "n" }, "<Esc>", function()
    api.nvim_win_close(win, true)
    vim.cmd("stopinsert")
  end, opts)
  
  -- Enter to confirm
  vim.keymap.set({ "i", "n" }, "<CR>", function()
    local new_name = vim.trim(api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "")
    api.nvim_win_close(win, true)
    vim.cmd("stopinsert")
    
    if #new_name > 0 and new_name ~= current_word then
      local params = vim.lsp.util.make_position_params()
      params.newName = new_name
      
      vim.lsp.buf_request(0, "textDocument/rename", params, custom_rename_handler)
    end
  end, opts)
  
  -- Clean up on buffer leave
  api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    once = true,
    callback = function()
      if api.nvim_win_is_valid(win) then
        api.nvim_win_close(win, true)
      end
    end,
  })
end

return M