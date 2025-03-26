return {
    cmd = {
        "clangd",
        "--background-index",
        "--offset-encoding=utf-16",
        "--clang-tidy",
    },
    root_markers = { "compile_commands.json", "compile_flags.txt", ".git/" },
    filetypes = { "c", "cpp" },
}
