return {
	"cormacrelf/dark-notify",
	dependencies = {
		{ "catppuccin", config = true },
	},
	config = function()
		local dn = require("dark_notify")
		dn.run({
			onchange = function(mode)
				if mode == "dark" then
					vim.cmd.colorscheme("catppuccin-mocha")
					vim.cmd("Catppuccin mocha")
				else
					vim.cmd.colorscheme("catppuccin-latte")
					vim.cmd("Catppuccin latte")
				end
				-- optional, you can configure your own things to react to changes.
				-- this is called at startup and every time dark mode is switched,
				-- either via the OS, or because you manually set/toggled the mode.
				-- mode is either "light" or "dark"
			end,
			-- schemes = {
			-- 	dark = "catppuccin-mocha",
			-- 	light = "catppuccin-latte",
			-- },
		})
	end,
}
