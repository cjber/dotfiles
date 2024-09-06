local spec = {
  "luukvbaal/statuscol.nvim",
  lazy = false,
  config = function()
    local builtin = require "statuscol.builtin"

    require("statuscol").setup {
      relculright = true,
      segments = {
        {
          text = { builtin.lnumfunc, " " },
          condition = { true, builtin.not_empty },
          click = "v:lua.ScLa",
        },
        { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
        { text = { "%s" }, condition = { true, builtin.not_empty }, click = "v:lua.ScSa" },
      },
    }
  end,
}

return spec
