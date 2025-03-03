-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)
--
-- Utility functions shared between progress reports for LSP and DAP

local client_notifs = {}

local function get_notif_data(client_id, token)
    if not client_notifs[client_id] then
        client_notifs[client_id] = {}
    end

    if not client_notifs[client_id][token] then
        client_notifs[client_id][token] = {}
    end

    return client_notifs[client_id][token]
end

local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

local function update_spinner(client_id, token)
    local notif_data = get_notif_data(client_id, token)

    if notif_data.spinner then
        local new_spinner = (notif_data.spinner + 1) % #spinner_frames
        notif_data.spinner = new_spinner

        notif_data.notification = vim.notify(nil, nil, {
            hide_from_history = true,
            icon = spinner_frames[new_spinner],
            replace = notif_data.notification,
        })

        vim.defer_fn(function()
            update_spinner(client_id, token)
        end, 100)
    end
end

local function format_title(title, client_name)
    return client_name .. (#title > 0 and ": " .. title or "")
end

local function format_message(message, percentage)
    return (percentage and percentage .. "%\t" or "") .. (message or "")
end

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
        return {
            -- Basic debugging keymaps, feel free to change to your liking!
            { "<F5>", dap.continue, desc = "Debug: Start/Continue" },
            { "<F1>", dap.step_into, desc = "Debug: Step Into" },
            { "<F2>", dap.step_over, desc = "Debug: Step Over" },
            { "<F3>", dap.step_out, desc = "Debug: Step Out" },
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
            -- controls = {
            --     icons = {
            --         pause = "⏸",
            --         play = "▶",
            --         step_into = "⏎",
            --         step_over = "⏭",
            --         step_out = "⏮",
            --         step_back = "b",
            --         run_last = "▶▶",
            --         terminate = "⏹",
            --         disconnect = "⏏",
            --     },
            -- },
        })

        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close
        dap.adapters.lldb = dap.adapters.codelldb

        -- Install golang specific config
        require("dap-go").setup({
            delve = {
                -- On Windows delve must be run attached or it crashes.
                -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
                detached = vim.fn.has("win32") == 0,
            },
        })
        -- DAP integration
        -- Make sure to also have the snippet with the common helper functions in your config!

        dap.listeners.before["event_progressStart"]["progress-notifications"] = function(
            session,
            body
        )
            local notif_data = get_notif_data("dap", body.progressId)

            local message = format_message(body.message, body.percentage)
            notif_data.notification = vim.notify(message, "info", {
                title = format_title(body.title, session.config.type),
                icon = spinner_frames[1],
                timeout = false,
                hide_from_history = false,
            })

            notif_data.notification.spinner = 1, update_spinner("dap", body.progressId)
        end

        dap.listeners.before["event_progressUpdate"]["progress-notifications"] = function(
            session,
            body
        )
            local notif_data = get_notif_data("dap", body.progressId)
            notif_data.notification =
                vim.notify(format_message(body.message, body.percentage), "info", {
                    replace = notif_data.notification,
                    hide_from_history = false,
                })
        end

        dap.listeners.before["event_progressEnd"]["progress-notifications"] = function(
            session,
            body
        )
            local notif_data = client_notifs["dap"][body.progressId]
            notif_data.notification =
                vim.notify(body.message and format_message(body.message) or "Complete", "info", {
                    icon = "",
                    replace = notif_data.notification,
                    timeout = 3000,
                })
            notif_data.spinner = nil
        end
    end,
}
