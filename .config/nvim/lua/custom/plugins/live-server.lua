if vim.fn.executable("node") == 1 then
    return {
        "barrett-ruth/live-server.nvim",
        build = "npm install -g live-server",
        cmd = { "LiveServerStart", "LiveServerStop" },
        config = true,
    }
end

return {}
