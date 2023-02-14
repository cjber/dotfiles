local present, alpha = pcall(require, "alpha")
if not present then
	return
end

local header = {
	type = "text",
	val = {

		[[         //                 /*]],
		[[      ,(/(//,               *###]],
		[[    ((((((////.             /####%*]],
		[[ ,/(((((((/////*            /########]],
		[[/*///((((((//////.          *#########/]],
		[[//////((((((((((((/         *#########/.]],
		[[////////((((((((((((*       *#########/.]],
		[[/////////(/(((((((((((      *#########(.]],
		[[//////////.,((((((((((/(    *#########(.]],
		[[//////////.  /(((((((((((,  *#########(.]],
		[[(////////(.    (((((((((((( *#########(.]],
		[[(////////(.     ,#((((((((((##########(.]],
		[[((//////((.       /#((((((((##%%######(.]],
		[[((((((((((.         #(((((((####%%##%#(.]],
		[[((((((((((.          ,((((((#####%%%%%(.]],
		[[ .#(((((((.            (((((#######%%]],
		[[    /(((((.             .(((#%##%%/*]],
		[[      ,(((.               /(#%%#]],
		[[        ./.                 #*]],
	},
	opts = { position = "center", hl = "NonText" },
}

local handle = io.popen('fd -d 1 . $HOME"/.local/share/nvim/lazy" | head -n -2 | wc -l | tr -d "\n" ')
local plugins = handle:read("*a")
handle:close()

local thingy = io.popen('echo "$(date +%a) $(date +%d) $(date +%b)" | tr -d "\n"')
local date = thingy:read("*a")
thingy:close()

local plugin_count = {
	type = "text",
	val = "└─   " .. plugins .. " plugins in total ─┘",
	opts = { position = "center", hl = "NonText" },
}

local heading = {
	type = "text",
	val = "┌─   Today is " .. date .. " ─┐",
	opts = { position = "center", hl = "NonText" },
}

local top_bar = {
	type = "text",
	val = "┌──══───══───══───══───══──┐",
	opts = { position = "center", hl = "NonText" },
}

local bot_bar = {
	type = "text",
	val = "└──══───══───══───══───══──┘",
	opts = { position = "center", hl = "NonText" },
}

local footer = {
	type = "text",
	val = "-cjber-",
	opts = { position = "center", hl = "NvimOptionName" },
}

local function button(sc, txt, keybind)
	local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")

	local opts = {
		position = "center",
		text = txt,
		shortcut = sc,
		cursor = 5,
		width = 24,
		align_shortcut = "right",
		hl_shortcut = "NonText",
		hl_text = "NonText",
		hl = "NonText",
	}
	if keybind then
		opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true } }
	end

	return {
		type = "button",
		val = txt,
		on_press = function()
			local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
			vim.api.nvim_feedkeys(key, "normal", false)
		end,
		opts = opts,
	}
end

local buttons = {
	type = "group",
	val = {
		button("e", "  New file", ":ene <BAR> startinsert <CR>"),
		button("f", "  Find file", ":Telescope find_files<CR>"),
		button("r", "  Recent", ":Telescope oldfiles<CR>"),
		button("a", "  Projects", ":Telescope projects<CR>"),
		button("s", "  Settings", ":cd $HOME/dotfiles/dotfiles/config/nvim | e $MYVIMRC<CR>"),
		button("q", "  Quit NVIM", ":qa<CR>"),
	},
	opts = { spacing = 1 },
}

local section = {
	header = header,
	buttons = buttons,
	plugin_count = plugin_count,
	heading = heading,
	top_bar = top_bar,
	bot_bar = bot_bar,
	footer = footer,
}

local opts = {
	layout = {
		{ type = "padding", val = 2 },
		section.header,
		{ type = "padding", val = 2 },
		section.heading,
		section.plugin_count,
		{ type = "padding", val = 3 },
		-- section.top_bar,
		section.buttons,
		-- section.bot_bar,
		{ type = "padding", val = 4 },
		section.footer,
	},
	opts = { margin = 5 },
}
alpha.setup(opts)
