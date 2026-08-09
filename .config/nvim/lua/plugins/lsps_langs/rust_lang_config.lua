return {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true
            },
            checkOnSave = true,
            check = {
                command = "clippy"
            },
            inlayHints = {
                enable = true,
                typeHints = true,
                parameterHints = true
            }
        }
    }
}
