local icons = require("nvim-nonicons")

require("vim.lsp.protocol").CompletionItemKind = {
	icons.get("typography") .. " (text)",
	icons.get("package") .. " (function)",
	icons.get("package") .. " (method)",
	icons.get("struct") .. " (constructor)",
	icons.get("field") .. " (field)",
	icons.get("variable") .. " (variable)",
	icons.get("class") .. " (class)",
	icons.get("interface") .. " (interface)",
	"{}(module)",
	icons.get("tools") .. " (property)",
	icons.get("note") .. " (unit)",
	icons.get("note") .. " (value)",
	icons.get("list-unordered") .. " (enum)",
	icons.get("typography") .. " (keyword)",
	icons.get("snippet") .. " (snippet)",
	icons.get("heart") .. " (color)", -- tmp
	icons.get("file") .. " (file)",
	icons.get("file-symlink-file") .. " (reference)",
	icons.get("file-directory-outline") .. " (folder)",
	icons.get("list-unordered") .. " (enum member)",
	icons.get("constant") .. " (constant)",
	icons.get("struct") .. " (struct)",
	icons.get("zap") .. " (event)",
	icons.get("diff") .. " (operator)",
	icons.get("type") .. " (type parameter)",
}
