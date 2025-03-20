vim.o.sessionoptions =
    "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

return {
    "rmagatti/auto-session",
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
        -- suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
        -- log_level = 'debug',
        no_restore_cmds = {
            function()
                -- load oil in case we're launching with a dir arg and there's no session
                require("oil").open(vim.fn.getcwd())
            end,
        },
        bypass_save_filetypes = {
            "oil",
            "NvimTree",
            "toggleterm",
            "help",
            "lspinfo",
            "checkhealth",
            "Trouble",
            "lazy",
            "mason",
        },
    },
}
