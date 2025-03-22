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
                if
                    (
                        vim.fn.argc() == 0
                        or (vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1)
                    )
                    and vim.api.nvim_get_option_value("buftype", { buf = 0 }) == ""
                then
                    -- load oil in case we're launching with a dir arg and there's no session
                    require("oil").open(vim.fn.getcwd())
                end
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
