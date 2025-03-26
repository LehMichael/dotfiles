return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
        "williamboman/mason.nvim",
        "nanotee/sqls.nvim",
    },
    config = function()
        -- add lsp servers to be installed by mason
        local ensure_installed = {
            "lua-language-server",
            "typos-lsp",
        }

        if vim.fn.executable("go") == 1 then
            table.insert(ensure_installed, "sqls")
        end

        if vim.fn.executable("node") == 1 then
            table.insert(ensure_installed, "html-lsp")
            table.insert(ensure_installed, "css-lsp")
            table.insert(ensure_installed, "typescript-language-server")
            table.insert(ensure_installed, "eslint-lsp")
            table.insert(ensure_installed, "json-lsp")
            table.insert(ensure_installed, "pyright")
        end

        require("mason-tool-installer").setup({
            ensure_installed = ensure_installed,
            auto_update = true,
            run_on_start = false,
            run_on_write = false,
        })

        -- add lsp servers without mason
        local lsps = {
            "gopls",
            "clangd",
        }

        -- check if the config exists and the executable is available, if so add it to the list
        for _, tool in ipairs(ensure_installed) do
            local name = type(tool) == "string" and tool or tool[1]
            local cfg = vim.lsp.config[name]

            if cfg and vim.fn.executable(cfg.cmd[1]) == 1 then
                table.insert(lsps, name)
            end
        end

        -- vim.print(lsps)
        vim.lsp.enable(lsps)

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if
                    client
                    and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint)
                then
                    vim.keymap.set("n", "<leader>th", function()
                        vim.lsp.inlay_hint.enable(
                            not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
                        )
                    end, { desc = "Toggle Inlay Hints" })
                end
            end,
        })
    end,
}
