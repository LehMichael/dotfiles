if not vim.fn.executable("java") then
    return {}
end

return {
    "mfussenegger/nvim-jdtls",
    dependencies = {
        "mfussenegger/nvim-dap",
        "mason-org/mason.nvim",
    },
    ft = "java",
    config = function()
        local mason_registry = require("mason-registry")
        local function ensure_installed(package_name)
            local pkg = mason_registry.get_package(package_name)
            if not pkg:is_installed() then
                pkg:install()
            end
        end

        ensure_installed("jdtls")
        ensure_installed("java-debug-adapter")
        ensure_installed("java-test")

        local function start_jdtls(args)
            local buf = args and args.buf or vim.api.nvim_get_current_buf()
            if vim.bo[buf].buftype ~= "" then
                return
            end

            local bundles = vim.fn.globpath("$MASON/share/java-debug-adapter", "*.jar", true, true)

            local java_test_bundles = vim.fn.globpath("$MASON/share/java-test", "*.jar", true, true)
            local excluded = {
                "com.microsoft.java.test.runner-jar-with-dependencies.jar",
                "jacocoagent.jar",
            }
            for _, java_test_jar in ipairs(java_test_bundles) do
                local fname = vim.fn.fnamemodify(java_test_jar, ":t")
                if not vim.tbl_contains(excluded, fname) then
                    table.insert(bundles, java_test_jar)
                end
            end

            local root_dir = vim.fs.root(buf, { "pom.xml", "gradlew", "mvnw" })
            if not root_dir then
                return
            end

            local project_name = vim.fn.fnamemodify(root_dir, ":t")
                .. "-"
                .. vim.fn.sha256(root_dir):sub(1, 8)
            local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace/") .. project_name

            local config = {
                name = "jdtls",

                -- `cmd` defines the executable to launch eclipse.jdt.ls.
                -- `jdtls` must be available in $PATH and you must have Python3.9 for this to work.
                --
                -- As alternative you could also avoid the `jdtls` wrapper and launch
                -- eclipse.jdt.ls via the `java` executable
                -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
                cmd = { "jdtls", "-data", workspace_dir },

                -- `root_dir` must point to the root of your project.
                -- See `:help vim.fs.root`
                root_dir = root_dir,

                -- Here you can configure eclipse.jdt.ls specific settings
                -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                -- for a list of options
                settings = {
                    java = {},
                },

                -- This sets the `initializationOptions` sent to the language server
                -- If you plan on using additional eclipse.jdt.ls plugins like java-debug
                -- you'll need to set the `bundles`
                --
                -- See https://codeberg.org/mfussenegger/nvim-jdtls#java-debug-installation
                --
                -- If you don't plan on any eclipse.jdt.ls plugins you can remove this
                init_options = {
                    bundles = bundles,
                },

                on_attach = function()
                    require("jdtls").setup_dap({ hotcodereplace = "auto" })
                end,
            }

            require("jdtls").start_or_attach(config)
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = start_jdtls,
        })

        -- also run immediately for the current buffer
        start_jdtls()
    end,
}
