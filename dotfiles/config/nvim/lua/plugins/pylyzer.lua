local util = require("lspconfig/util")

local server_name = "pylyzer"

return {
	default_config = {
		cmd = { server_name, "--server" },
		filetypes = { "python" },
		root_dir = function(fname)
			local root_files = {
				"pyproject.toml",
				"setup.py",
				"setup.cfg",
				"requirements.txt",
				"Pipfile",
			}
			return util.root_pattern(unpack(root_files))(fname)
				or util.find_git_ancestor(fname)
				or util.path.dirname(fname)
		end,
	},
}
