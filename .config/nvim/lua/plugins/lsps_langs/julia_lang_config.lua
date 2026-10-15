return {
    cmd = {
        "julia",
        "--startup-file=no",
        "--history-file=no",
        "-e",
        [[
            push!(LOAD_PATH, "@nvim-lsp")
            using LanguageServer
            runserver()
        ]]
    },
    filetypes = { "julia" },
    root_markers = { "Project.toml", "JuliaProject.toml", ".git" }
}
