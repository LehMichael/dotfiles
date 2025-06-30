return {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- or if using mini.icons/mini.nvim
    -- dependencies = { "echasnovski/mini.icons" },
    lazy = false,
    opts = {
        register_ui_select = true,
        grep = {
            hidden = true,
        },
    },
    init = function()
        require("fzf-lua").register_ui_select()
    end,
    keys = {
        {
            "<leader>sf",
            function()
                require("fzf-lua").files()
            end,
            desc = "Search Files",
        },
        {
            "<leader>sg",
            function()
                require("fzf-lua").live_grep()
            end,
            desc = "Live Grep",
        },
        {
            "<leader>sb",
            function()
                require("fzf-lua").buffers()
            end,
            desc = "Search Buffers",
        },
        {
            "<leader>sn",
            function()
                require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
            end,
            desc = "Search Neovim Config",
        },
        {
            "<leader>sd",
            function()
                require("fzf-lua").diagnostics_document()
            end,
            desc = "Search Document Diagnostics",
        },
        {
            "<leader>sD",
            function()
                require("fzf-lua").diagnostics_workspace()
            end,
            desc = "Search Workspace Diagnostics",
        },
        {
            "<leader>sr",
            function()
                require("fzf-lua").resume()
            end,
            desc = "Resume Last Search",
        },
        {
            "grr",
            function()
                require("fzf-lua").lsp_references()
            end,
            desc = "Search LSP References",
        },
        {
            "gd",
            function()
                require("fzf-lua").lsp_definitions()
            end,
            desc = "Search LSP Definitions",
        },
        {
            "gD",
            function()
                require("fzf-lua").lsp_declarations()
            end,
            desc = "Search LSP Declarations",
        },
    },
}
