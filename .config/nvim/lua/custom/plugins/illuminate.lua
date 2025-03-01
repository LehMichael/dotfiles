return {
    "rockyzhang24/vim-illuminate",
    branch = "fix-encoding",
    config = function()
        require("illuminate").configure({})
    end,
}
