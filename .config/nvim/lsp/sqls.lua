return {
    cmd = { "sqls" },
    filetypes = { "sql", "mysql" },
    root_patters = { ".git", "sqls.yml" },
    single_file_support = true,
    settings = {},
    on_new_config = function(config, root_dir)
        vim.print("on_new_config", config, root_dir)
        local conf_path = vim.fs.joinpath(root_dir, "sqls.yml")

        if vim.fn.filereadable(conf_path) == 1 then
            config.cmd = {
                "sqls",
                "-config",
                conf_path,
            }
        end
    end,
    on_attach = function(client, bufnr)
        require("sqls").on_attach(client, bufnr)
    end,
}
