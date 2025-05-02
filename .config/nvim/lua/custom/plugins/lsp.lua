return {
    "neovim/nvim-lspconfig",
    dependencies = {
        { "williamboman/mason.nvim", config = true },
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",

        { "j-hui/fidget.nvim", opts = {} },

        "nanotee/sqls.nvim",
    },
    config = function()
        -- vim.lsp.set_log_level("debug")
        vim.lsp.set_log_level(vim.lsp.log_levels.WARN)
        -- vim.lsp.set_log_level("off")

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                end

                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if
                    client
                    and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint)
                then
                    map("<leader>th", function()
                        vim.lsp.inlay_hint.enable(
                            not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
                        )
                    end, "Toggle Inlay Hints")
                end
            end,
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities =
            vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

        local ensure_installed = {}

        local servers = {
            --
            templ = {},

            lua_ls = {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                        hint = { enable = true },
                        diagnostics = { disable = { "missing-fields" } },
                    },
                },
            },
            typos_lsp = {
                init_options = {
                    diagnosticSeverity = "Info",
                },
            },
        }

        if vim.fn.executable("clangd") then
            servers.clangd = {
                cmd = {
                    "clangd",
                    "--offset-encoding=utf-16",
                    "--background-index",
                    "--clang-tidy",
                },
                root_dir = function(fname)
                    return vim.fs.dirname(fname)
                end,
                settings = {
                    clangd = {
                        InlayHints = {
                            Designators = true,
                            Enabled = true,
                            ParameterNames = true,
                            DeducedTypes = true,
                        },
                        fallbackFlags = { "-std=c++20" },
                    },
                },
            }
        end

        local has_tailwind = function()
            -- Search up for package.json and check if it includes "tailwindcss"
            local package_json = vim.fs.find("package.json", { upward = true, limit = 1 })[1]
            if not package_json then
                return false
            end

            local ok, content = pcall(vim.fn.readfile, package_json)
            if not ok then
                return false
            end

            local text = table.concat(content, "\n")
            return text:find('"tailwindcss"%s*:') ~= nil
        end

        if vim.fn.executable("node") == 1 then
            if has_tailwind() then
                servers.tailwindcss = {}
            else
                servers.cssls = {}
            end
            servers.volar = {}
            local mason_registry = require("mason-registry")
            local vue_language_server_path = mason_registry
                .get_package("vue-language-server")
                :get_install_path() .. "/node_modules/@vue/language-server"

            servers.html = {
                filetypes = { "html", "handlebars", "hbs" },
            }
            servers.ts_ls = {
                settings = {
                    complete_function_calls = true,
                    vtsls = {
                        enableMoveToFileCodeAction = true,
                        autoUseWorkspaceTsdk = true,
                        experimental = {
                            maxInlayHintLength = 30,
                            completion = {
                                enableServerSideFuzzyMatch = true,
                            },
                        },
                    },
                    typescript = {
                        updateImportsOnFileMove = { enabled = "always" },
                        suggest = {
                            completeFunctionCalls = true,
                        },
                        inlayHints = {
                            enumMemberValues = { enabled = true },
                            functionLikeReturnTypes = { enabled = true },
                            parameterNames = { enabled = "literals" },
                            parameterTypes = { enabled = true },
                            propertyDeclarationTypes = { enabled = true },
                            variableTypes = { enabled = false },
                        },
                    },
                },
                init_options = {
                    plugins = {
                        {
                            name = "@vue/typescript-plugin",
                            location = vue_language_server_path,
                            languages = { "vue" },
                        },
                    },
                },
                filetypes = {
                    "typescript",
                    "javascript",
                    "javascriptreact",
                    "typescriptreact",
                    "vue",
                },
            }
            servers.eslint = {}
            servers.jsonls = {}
            servers.pyright = {}
        end

        if vim.fn.executable("go") == 1 then
            servers.gopls = {
                settings = {
                    gopls = {
                        hints = {
                            rangeVariableTypes = true,
                            parameterNames = true,
                            constantValues = true,
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            functionTypeParameters = true,
                        },
                        analyses = {
                            shadow = true,
                        },
                        staticcheck = true,
                    },
                },
            }
            servers.sqls = {
                -- change filename from default config.yml to .sqls.yml
                -- root_dir = require("lspconfig").util.root_pattern("sqls.yml"),
                root_dir = vim.fs.root(0, "sqls.yml"),
                on_new_config = function(config, root_dir)
                    local conf_path = vim.fs.joinpath(root_dir, "sqls.yml")

                    if vim.fn.filereadable(conf_path) == 1 then
                        config.cmd = {
                            "sqls",
                            "-config",
                            conf_path,
                        }
                    end
                end,
                on_attach = function(client, bufnr)
                    require("sqls").on_attach(client, bufnr)
                end,
            }
        end

        require("mason").setup()

        vim.list_extend(ensure_installed, vim.tbl_keys(servers or {}))

        if vim.fn.system("arch"):find("aarch64") then
            for k, v in ipairs(ensure_installed) do
                if v == "clangd" then
                    table.remove(ensure_installed, k)
                    break
                end
            end
        end

        require("mason-lspconfig").setup({
            ensure_installed = ensure_installed,
            automatic_installation = false,
        })

        for key, server in pairs(servers) do
            server.capabilities =
                vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})

            require("lspconfig")[key].setup(server)
        end
    end,
}
