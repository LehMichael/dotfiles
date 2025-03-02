return {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        {
            "mike-jl/harpoonEx",
            -- dev = true,
            opts = {
                reload_on_dir_change = true,
                reload_on_tab_enter = true,
            },
        },
    },

    config = function()
        local harpoon = require("harpoon")
        local harpoonEx = require("harpoonEx")

        harpoon:setup({
            default = {
                select_with_nil = true,
            },
        })

        vim.keymap.set("n", "<M-a>", function()
            harpoon:list():add()
        end, { desc = "Add current filte to Harpoon List" })
        vim.keymap.set("n", "<M-d>", function()
            harpoonEx.delete(harpoon:list())
        end, { desc = "Add current filte to Harpoon List" })

        vim.keymap.set("n", "<M-e>", function()
            require("telescope").extensions.harpoonEx.harpoonEx({
                -- Optional: define mappings, default mappings:
                attach_mappings = function(_, map)
                    local actions = require("telescope").extensions.harpoonEx.actions
                    map("n", "dd", actions.delete_mark)
                    return true
                end,
            })
            return true
        end, { desc = "Open harpoon window" })

        for i = 1, 9 do
            vim.keymap.set("n", "<M-" .. i .. ">", function()
                require("harpoon"):list():select(i)
            end)
        end

        local extensions = require("harpoon.extensions")
        -- Setup keymaps for number row
        harpoon:extend(extensions.builtins.navigate_with_number())
        harpoon:extend(harpoonEx.extend())

        -- Toggle previous & next buffers stored within Harpoon list
        vim.keymap.set("n", "<S-Tab>", function()
            harpoonEx.next_harpoon(harpoon:list(), true)
        end, { desc = "Switch to previous buffer in Harpoon List" })
        vim.keymap.set("n", "<Tab>", function()
            harpoonEx.next_harpoon(harpoon:list(), false)
        end, { desc = "Switch to next buffer in Harpoon List" })

        vim.keymap.set("n", "<leader>sh", function()
            harpoonEx.telescope_live_grep(harpoon:list())
        end, { desc = "Live grep harpoon files" })
    end,

    init = function()
        local harpoon = require("harpoon")
        local harpoonEx = require("harpoonEx")
        -- check if nvim was started with no arguments or just a dir as argument
        -- if so, try to select the first item in the harpoon list
        if
            (vim.fn.argc() == 0 or (vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1))
            and vim.api.nvim_get_option_value("buftype", { buf = 0 }) == ""
        then
            vim.schedule(function()
                harpoonEx.next_harpoon(harpoon:list(), false)
            end)
        end
    end,
}
