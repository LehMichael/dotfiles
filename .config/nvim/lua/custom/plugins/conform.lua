local conform = { -- Auto
    "stevearc/conform.nvim",
    dependencies = {},
    opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
            end
            -- Disable "format_on_save lsp_fallback" for languages that don't
            -- have a well standardized coding style. You can add additional
            -- languages here or re-enable it for the disabled ones.
            local disable_filetypes = { c = true, cpp = true }
            local lsp_format_opt
            if disable_filetypes[vim.bo[bufnr].filetype] then
                lsp_format_opt = "never"
            else
                lsp_format_opt = "fallback"
            end
            return {
                timeout_ms = 500,
                lsp_format = lsp_format_opt,
            }
        end,
        formatters_by_ft = {
            lua = { "stylua" },
            c = { "clang-format" },
            cpp = { "clang-format" },
            -- Conform can also run multiple formatters sequentially
            -- python = { "isort", "black" },
            --
            -- You can use a sub-list to tell conform to run *until* a formatter
            -- is found.
            -- javascript = { { "prettierd", "prettier" } },
            sql = { "sqlfmt" },
            templ = { "templ" },
            vue = { "prettier" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            json = { "prettier" },
            html = { "prettier" },
            css = { "prettier" },
            scss = { "prettier" },
            yaml = { "prettier" },
        },
        formatters = {},
    },
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({ async = true, lsp_format = "fallback" })
            end,
            mode = "",
            desc = "[F]ormat buffer",
        },
    },
    init = function()
        vim.api.nvim_create_user_command("FormatDisable", function(args)
            if args.bang then
                -- FormatDisable! will disable formatting just for this buffer
                vim.b.disable_autoformat = true
            else
                vim.g.disable_autoformat = true
            end
        end, {
            desc = "Disable autoformat-on-save",
            bang = true,
        })
        vim.api.nvim_create_user_command("FormatEnable", function()
            vim.b.disable_autoformat = false
            vim.g.disable_autoformat = false
        end, {
            desc = "Re-enable autoformat-on-save",
        })

        local conform = require("conform")
        -- Keep original format function
        local original_format = conform.format

        -- Wrap it with your post-format hook
        ---@diagnostic disable-next-line: duplicate-set-field
        conform.format = function(opts, callback)
            original_format(opts, function(err, did_edit)
                local bufnr = opts.bufnr or 0

                vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("silent! Sleuth")
                end)

                -- Call user's callback if they provided one
                if callback then
                    callback(err, did_edit)
                end
            end)
        end
    end,
}

if vim.fn.executable("go") == 1 then
    conform.opts.formatters_by_ft.go = { "gofumpt", "golines" }
    conform.opts.formatters.golines = {
        prepend_args = { "-m", "100" },
    }
end

conform.opts.formatters.prettier = {
    prepend_args = function()
        return {
            "--single-quote",
            "--no-bracket-spacing",
            "--print-width",
            "80",
            "--tab-width",
            "4",
            "--config-precedence",
            "prefer-file",
        }
    end,
}

local masonconform = {
    "zapling/mason-conform.nvim",
    dependencies = {
        "stevearc/conform.nvim",
        { "williamboman/mason.nvim", config = true },
    },
    opts = {},
}

return { conform, masonconform }
