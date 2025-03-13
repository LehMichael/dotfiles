-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = { only_current_line = true },
})

-- Disable the plugin in Lazy.nvim
vim.api.nvim_create_autocmd("FileType", {
    pattern = "lazy",
    callback = function()
        local previous = not require("lsp_lines").toggle()
        if not previous then
            require("lsp_lines").toggle()
        end
    end,
})

return {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    opts = {},
}
