return {
    cmd = { "emmylua_ls" },
    settings = {
        emmylua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1]
                }
            }
        }
    }
}
