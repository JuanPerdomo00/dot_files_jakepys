return {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly", --  "workspace" all projects
                typeCheckingMode = "basic"        -- options "off", "basic", "strict"
            }
        }
    }
}
