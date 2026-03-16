return {
    { -- This plugin
        "Zeioth/compiler.nvim",
        cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
        -- dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
        opts = {},
    },
    {
        "stevearc/overseer.nvim",
        opts = {},
        lazy = false,
        keys = {
            {
                "<leader>oo",
                function()
                    require("overseer").toggle()
                end,
                desc = "Overseer Toggle",
            },
            {
                "<leader>or",
                function()
                    require("overseer").run_task({})
                end,
                desc = "Overseer Toggle",
            },
        },
    },
}
