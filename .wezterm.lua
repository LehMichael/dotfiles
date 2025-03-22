local wezterm = require("wezterm")
local mux = wezterm.mux

-- wezterm.on("gui-startup", function(cmd)
-- 	local tab, pane, window = mux.spawn_window(cmd or {})
-- window:gui_window():maximize()
-- end)
local cache_dir = os.getenv("HOME") .. "/.cache/wezterm/"
local window_size_cache_path = cache_dir .. "window_size_cache.txt"

wezterm.on("gui-startup", function()
	os.execute("mkdir " .. cache_dir)

	local window_size_cache_file = io.open(window_size_cache_path, "r")
	local window
	if window_size_cache_file ~= nil then
		local _, _, width, height = string.find(window_size_cache_file:read(), "(%d+),(%d+)")
		_, _, window =
			mux.spawn_window({ width = tonumber(width), height = tonumber(height), position = { x = 0, y = 0 } })
		window_size_cache_file:close()
	else
		_, _, window = mux.spawn_window({})
		window:gui_window():maximize()
	end
end)

wezterm.on("window-resized", function(_, pane)
	local tab_size = pane:tab():get_size()
	local cols = tab_size["cols"]
	local rows = tab_size["rows"] + 2 -- Without adding the 2 here, the window doesn't maximize
	local contents = string.format("%d,%d", cols, rows)

	local window_size_cache_file = io.open(window_size_cache_path, "w")
	-- Check if the file was successfully opened
	if window_size_cache_file then
		window_size_cache_file:write(contents)
		window_size_cache_file:close()
	else
		print("Error: Could not open file for writing: " .. window_size_cache_path)
	end
end)

local config = {}
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "DemiBold" })
-- config.front_end = "OpenGL"
-- config.font = wezterm.font("JetBrains Mono", { weight = "DemiBold" })
config.font_size = 11
-- config.freetype_render_target = "HorizontalLcd"
config.cell_width = 0.9

-- config.window_decorations = "RESIZE"
-- config.tab_bar_at_bottom = true
-- config.color_scheme = "Catppuccin Mocha"

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Mocha"
	else
		return "Catppuccin Latte"
	end
end

config.color_scheme = scheme_for_appearance(get_appearance())
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 5,
	right = 5,
	top = 5,
	bottom = 5,
}
-- config.native_macos_fullscreen_mode = true
-- config.default_prog = { "/opt/homebrew/bin/tmux", "new", "-As0" }
-- config.default_prog = { "zsh", "-l", "-c", "/opt/homebrew/bin/tmux", "new", "-As0" }
config.window_close_confirmation = "NeverPrompt"
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.keys = {
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

-- config.window_background_opacity = 0.9
-- config.macos_window_background_blur = 30

return config
