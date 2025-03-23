return { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VeryLazy", -- Sets the loading event to 'VimEnter'
    opts = {
        -- debug = true,
        icons = { rules = false },
        spec = {
            { "<leader>c", group = "[C]ode" },
            { "<leader>d", group = "[D]ocument" },
            { "<leader>r", group = "[R]ename" },
            { "<leader>s", group = "[S]earch" },
            { "<leader>w", group = "[W]orkspace" },
            { "<leader>t", group = "[T]oggle" },
            { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
            {
                { "n", hidden = true },
                { "N", hidden = true },
                { "<leader>y", hidden = true, mode = { "n", "v" } },
                { "<leader>Y", hidden = true },
            },
        },
    },
}
