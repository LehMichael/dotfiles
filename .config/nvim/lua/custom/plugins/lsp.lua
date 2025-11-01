return {
    "neovim/nvim-lspconfig",
    dependencies = {
        { "mason-org/mason.nvim", config = true },
        "mason-org/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",

        { "j-hui/fidget.nvim", opts = {} },

        "nanotee/sqls.nvim",
    },
    config = function()
        -- vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
        -- vim.lsp.set_log_level(vim.lsp.log_levels.WARN)
        vim.lsp.set_log_level(vim.lsp.log_levels.OFF)

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

        local servers = {
            mason = {
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
            },
            others = {},
        }

        if vim.fn.executable("cargo") then
            servers.mason.rust_analyzer = {
                settings = {
                    ["rust-analyzer"] = {
                        check = {
                            ignore = { "dead_code" },
                        },
                    },
                },
            }
        end

        if vim.fn.executable("clangd") then
            servers.others.clangd = {
                cmd = {
                    "clangd",
                    "--offset-encoding=utf-16",
                    "--background-index",
                    "--clang-tidy",
                },
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

        if vim.fn.executable("sourcekit-lsp") == 1 then
            servers.others.sourcekit = {}
        end

        if vim.fn.executable("node") == 1 then
            if has_tailwind() then
                servers.mason.tailwindcss = {}
            else
                servers.mason.cssls = {}
            end

            servers.mason.html = {
                filetypes = { "html", "handlebars", "hbs" },
            }

            servers.mason.vue_ls = {}
            local vue_language_server_path = vim.fn.expand(
                "$MASON/packages/vue-language-server/node_modules/@vue/language-server"
            )

            servers.mason.ts_ls = {
                settings = {
                    complete_function_calls = true,
                    -- vtsls = {
                    --     enableMoveToFileCodeAction = true,
                    --     autoUseWorkspaceTsdk = true,
                    --     experimental = {
                    --         maxInlayHintLength = 30,
                    --         completion = {
                    --             enableServerSideFuzzyMatch = true,
                    --         },
                    --     },
                    -- },
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
            servers.mason.eslint = {}
            servers.mason.jsonls = {}
            servers.mason.pyright = {}
        end

        if vim.fn.executable("go") == 1 then
            servers.mason.gopls = {
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
            -- servers.sqls = {
            --     -- change filename from default config.yml to .sqls.yml
            --     -- root_dir = require("lspconfig").util.root_pattern("sqls.yml"),
            --     root_dir = vim.fs.root(0, "sqls.yml"),
            --     on_new_config = function(config, root_dir)
            --         local conf_path = vim.fs.joinpath(root_dir, "sqls.yml")
            --
            --         if vim.fn.filereadable(conf_path) == 1 then
            --             config.cmd = {
            --                 "sqls",
            --                 "-config",
            --                 conf_path,
            --             }
            --         end
            --     end,
            --     on_attach = function(client, bufnr)
            --         require("sqls").on_attach(client, bufnr)
            --     end,
            -- }
        end

        if vim.fn.executable("zig") then
            servers.mason.zls = {}
        end

        require("mason").setup()

        local ensure_installed = vim.tbl_keys(servers.mason or {})

        require("mason-lspconfig").setup({
            ensure_installed = ensure_installed,
            automatic_enable = false,
        })

        -- for key, server in pairs(servers) do
        --     server.capabilities =
        --         vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
        --
        --     require("lspconfig")[key].setup(server)
        -- end
        for server, config in pairs(vim.tbl_extend("keep", servers.mason, servers.others)) do
            if not vim.tbl_isempty(config) then
                vim.lsp.config(server, config)
            end
            vim.lsp.enable(server)
        end

        -- Manually run vim.lsp.enable for all language servers that are *not* installed via Mason
        -- if not vim.tbl_isempty(servers.others) then
        -- vim.lsp.enable(vim.tbl_keys(servers.others))
        -- end
    end,
}
