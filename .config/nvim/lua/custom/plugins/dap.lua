return {
    "mfussenegger/nvim-dap",
    dependencies = {
        -- Creates a beautiful debugger UI
        "rcarriga/nvim-dap-ui",

        -- Required dependency for nvim-dap-ui
        "nvim-neotest/nvim-nio",

        -- Installs the debug adapters for you
        "williamboman/mason.nvim",
        "jay-babu/mason-nvim-dap.nvim",

        "stevearc/overseer.nvim",

        -- Add your own debuggers here
        "leoluz/nvim-dap-go",
    },
    keys = function(_, keys)
        local dap = require("dap")
        local dapui = require("dapui")

        local last_config
        dap.listeners.after.event_initialized["some-unique-id"] = function(session)
            last_config = session.config
        end

        return {
            -- Basic debugging keymaps, feel free to change to your liking!
            {
                "<F5>",
                function()
                    if last_config and not dap.session() then
                        dap.run_last()
                        return
                    end
                    dap.continue()
                end,
                desc = "Debug: Start/Continue",
            },
            {
                "<F17>",
                function()
                    dap.terminate({ all = true })
                end,
                desc = "Debug: Stop",
            },
            { "<F11>", dap.step_into, desc = "Debug: Step Into" },
            { "<F10>", dap.step_over, desc = "Debug: Step Over" },
            { "<F23>", dap.step_out, desc = "Debug: Step Out" },
            { "<leader>b", dap.toggle_breakpoint, desc = "Debug: Toggle Breakpoint" },
            {
                "<leader>B",
                function()
                    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
                end,
                desc = "Debug: Set Breakpoint",
            },
            -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
            { "<F7>", dapui.toggle, desc = "Debug: See last session result." },
            unpack(keys),
        }
    end,
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        local ensure_installed = {
            "codelldb",
            "cppdbg",
            "js",
        }

        if vim.fn.executable("go") == 1 then
            vim.list_extend(ensure_installed, {
                "delve",
            })
        end

        require("mason-nvim-dap").setup({
            -- Makes a best effort to setup the various debuggers with
            -- reasonable debug configurations
            automatic_installation = true,

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            handlers = {
                function(config)
                    -- all sources with no handler get passed here

                    -- Keep original functionality
                    require("mason-nvim-dap").default_setup(config)
                end,
            },

            -- You'll need to check that you have the required things installed
            -- online, please don't ask me how to install them :)
            ensure_installed = ensure_installed,
        })

        vim.keymap.set("n", "<leader>B", function()
            dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, { desc = "Debug: Set Breakpoint" })

        vim.fn.sign_define(
            "DapBreakpoint",
            { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" }
        )
        vim.fn.sign_define(
            "DapBreakpointCondition",
            { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
        )
        vim.fn.sign_define(
            "DapLogPoint",
            { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" }
        )

        -- Dap UI setup
        -- For more information, see |:help nvim-dap-ui|
        dapui.setup({
            -- Set icons to characters that are more likely to work in every terminal.
            --    Feel free to remove or use ones that you like more! :)
            --    Don't feel like these are good choices.
            icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
            controls = {
                element = "repl",
                enabled = true,
                icons = {
                    disconnect = "",
                    pause = "",
                    play = "<F5> ",
                    run_last = "",
                    step_back = "",
                    step_into = "<F11> ",
                    step_out = "<S-F11> ",
                    step_over = "<F10> ",
                    terminate = "<S-F5> ",
                },
            },
        })

        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close
        dap.adapters.lldb = dap.adapters.codelldb

        local jspath
        local ok = pcall(function()
            jspath = vim.fs.joinpath(
                require("mason-registry").get_package("js-debug-adapter"):get_install_path(),
                "/js-debug/src/dapDebugServer.js"
            )
        end)

        if ok and vim.fn.filereadable(jspath) then
            local node_adapter = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = { jspath, "${port}" },
                },
                enrich_config = function(conf, on_config)
                    if not vim.startswith(conf.type, "pwa-") then
                        local config = vim.deepcopy(conf)
                        config.type = "pwa-" .. config.type
                        on_config(config)
                    else
                        on_config(conf)
                    end
                end,
            }

            dap.adapters["pwa-node"] = node_adapter
            dap.adapters["node"] = node_adapter

            dap.configurations.javascript = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                },
            }
        end

        -- Install golang specific config
        require("dap-go").setup({
            delve = {
                -- On Windows delve must be run attached or it crashes.
                -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
                detached = vim.fn.has("win32") == 0,
            },
        })
    end,
}
