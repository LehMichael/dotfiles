return {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,

    init = function()
        require("catppuccin").setup({
            flavour = "auto", -- latte, frappe, macchiato, mocha
            background = { -- :h background
                light = "latte",
                dark = "mocha",
            },
            -- transparent_background = true,
            custom_highlights = function(colors)
                return {
                    LspSignatureActiveCust = { bg = colors.surface1, style = { "bold" } },
                }
            end,
            integrations = {
                dap = true,
                dap_ui = true,
                which_key = true,
                telescope = {
                    enabled = true,
                    -- style = "nvchad"
                },
                notify = true,
                vim_sneak = true,
            },
        })
        vim.cmd.colorscheme("catppuccin")
    end,
}
