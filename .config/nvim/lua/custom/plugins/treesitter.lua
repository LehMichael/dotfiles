return { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    branch = "main",
    config = function()
        local mason_registry = require("mason-registry")
        local function ensure_installed(package_name)
            local pkg = mason_registry.get_package(package_name)
            if not pkg:is_installed() then
                pkg:install()
            end
        end
        ensure_installed("tree-sitter-cli")

        local parsers = {
            "bash",
            "c",
            "diff",
            "html",
            "lua",
            "luadoc",
            "markdown",
            "markdown_inline",
            "query",
            "vim",
            "vimdoc",
        }
        require("nvim-treesitter").install(parsers)

        -- tracks languages we've already attempted to install this session
        -- so we don't spam install on every buffer open
        local install_attempted = {}

        local function activate_treesitter(buf, language)
            if not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            if not vim.treesitter.language.add(language) then
                return false
            end
            vim.treesitter.start(buf, language)
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            return true
        end

        local available = require("nvim-treesitter").get_available()

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                local buf, filetype = args.buf, args.match

                local language = vim.treesitter.language.get_lang(filetype)
                if not language then
                    return
                end

                -- parser already available — just activate
                if activate_treesitter(buf, language) then
                    return
                end

                -- parser missing — attempt install once per language per session if its available
                if not vim.tbl_contains(available, language) or install_attempted[language] then
                    return
                end
                install_attempted[language] = true

                require("nvim-treesitter").install(language):await(function()
                    activate_treesitter(buf, language)
                end)
            end,
        })
    end,
}
