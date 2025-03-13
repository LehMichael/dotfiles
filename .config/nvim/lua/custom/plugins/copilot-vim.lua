return {
    "github/copilot.vim",
    config = function()
        -- vim.g.copilot#enable()
        local map = vim.keymap.set

        vim.g.copilot_no_tab_map = true
        vim.g.copilot_settings = { selectedCompletionModel = "gpt-4o-copilot" }
        vim.g.copilot_integration_id = "vscode-chat"

        map("i", "<M-]>", "<Plug>(copilot-next)", {})
        map("i", "<M-[>", "<Plug>(copilot-previous)", {})
        map("i", "<M-CR>", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })
        map("i", "<M-w>", "<Plug>(copilot-accept-word)")
        map("i", "<M-l>", "<Plug>(copilot-accept-line)")
        map("i", "<M-c>", "<Plug>(copilot-dismiss)")
    end,
}
