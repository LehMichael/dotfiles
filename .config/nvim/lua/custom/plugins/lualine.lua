for i = 1, 9 do
    vim.keymap.set("n", "<M-" .. i .. ">", "<cmd>LualineBuffersJump! " .. i .. "<CR>")
end

return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    opts = {
        options = {
            theme = "catppuccin",
            -- globalstatus = true,
        },
        extensions = { "oil" },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = { "filename" },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = {},
            lualine_z = { "location" },
        },
        tabline = {
            lualine_a = {
                {
                    "buffers",
                    show_filename_only = false, -- Shows shortened relative path when set to false.
                    -- hide_filename_extension = false, -- Hide filename extension when set to true.
                    -- show_modified_status = true, -- Shows indicator when the buffer is modified.
                    --
                    mode = 2, -- 0: Shows buffer name
                    -- -- 1: Shows buffer index
                    -- -- 2: Shows buffer name + buffer index
                    -- -- 3: Shows buffer number
                    -- -- 4: Shows buffer name + buffer number
                    --
                    max_length = vim.o.columns, -- * 2 / 3, -- Maximum width of buffers component,
                    -- -- it can also be a function that returns
                    -- -- the value of `max_length` dynamically.
                    -- filetype_names = {
                    -- 	TelescopePrompt = "Telescope",
                    -- 	dashboard = "Dashboard",
                    -- 	packer = "Packer",
                    -- 	fzf = "FZF",
                    -- 	alpha = "Alpha",
                    -- }, -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )
                    --
                    -- -- Automatically updates active buffer color to match color of other components (will be overridden if buffers_color is set)
                    use_mode_colors = true,
                    --
                    -- buffers_color = {
                    -- 	-- Same values as the general color option can be used here.
                    -- 	active = "lualine_{section}_normal", -- Color for active buffer.
                    -- 	inactive = "lualine_{section}_inactive", -- Color for inactive buffer.
                    -- },
                    --
                    -- symbols = {
                    -- 	modified = " ●", -- Text to show when the buffer is modified
                    -- 	alternate_file = "#", -- Text to show to identify the alternate file
                    -- 	directory = "", -- Text to show when the buffer is a directory
                    -- },
                },
            },
        },
    },
}
