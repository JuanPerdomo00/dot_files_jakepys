return {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed"
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = {
        "compile_commands.json",
        "compile_flags.txt",
        ".clangd",
        ".git"
    }
}
