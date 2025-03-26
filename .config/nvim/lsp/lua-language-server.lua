return {

    cmd = { "lua-language-server" },
    root_markers = {
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
        ".git",
    },
    filetypes = { "lua" },

    settings = {
        Lua = {
            completion = {
                callSnippet = "Replace",
            },
            hint = { enable = true },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = { disable = { "missing-fields" } },
        },
    },

    on_init = function(client)
        local path = vim.tbl_get(client, "workspace_folders", 1, "name")
        if not path then
            return
        end
        -- override the lua-language-server settings for Neovim config
        client.settings = vim.tbl_deep_extend("force", client.settings, {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                -- Make the server aware of Neovim runtime files
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                        -- Depending on the usage, you might want to add additional paths here.
                        -- "${3rd}/luv/library"
                        -- "${3rd}/busted/library",
                    },
                },
            },
        })
    end,
}
