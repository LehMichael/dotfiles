local git_ignored = setmetatable({}, {
    __index = function(self, key)
        local proc = vim.system(
            { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
            {
                cwd = key,
                text = true,
            }
        )
        local result = proc:wait()
        local ret = {}
        if result.code == 0 then
            for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
                -- Remove trailing slash
                line = line:gsub("/$", "")
                table.insert(ret, line)
            end
        end

        rawset(self, key, ret)
        return ret
    end,
})

return {
    "refractalize/oil-git-status.nvim",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        {
            "stevearc/oil.nvim",
            opts = {
                delete_to_trash = true,
                view_options = {
                    show_hidden = false,
                    is_always_hidden = function(name, _)
                        return name == ".."
                    end,
                    is_hidden_file = function(name, _)
                        -- dotfiles are always considered hidden
                        -- if vim.startswith(name, ".") then
                        -- 	return true
                        -- end
                        if name == ".git" then
                            return true
                        end
                        local dir = require("oil").get_current_dir()
                        -- if no local directory (e.g. for ssh connections), always show
                        if not dir then
                            return false
                        end
                        -- Check if file is gitignored
                        return vim.list_contains(git_ignored[dir], name)
                    end,
                },
                win_options = {
                    signcolumn = "yes:2",
                },
            },
        },
    },
    opts = {},
    keys = {
        {
            "-",
            function()
                require("oil").open()
            end,
            desc = "Open Oil",
        },
        {
            "<leader>-",
            function()
                require("oil").open(vim.fn.getcwd())
            end,
            desc = "Open Oil (cwd)",
        },
    },
}
