require("mason").setup()

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format Local buffer" })
vim.keymap.set("n", "df", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

vim.diagnostic.config({ virtual_text = true })

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("mini.completion").get_lsp_capabilities())

vim.lsp.config("*", { capabilities = capabilities })

local servers_configs = {
    emmylua_ls = "plugins.lsps_langs.lua_lang_config",
    pyright = "plugins.lsps_langs.python_lang_config",
    ts_ls = "plugins.lsps_langs.typescript_lang_config",
    dockerls = "plugins.lsps_langs.docker_lang_config",
    rust_analyzer = "plugins.lsps_langs.rust_lang_config",
    html = "plugins.lsps_langs.html_lang_config",
    jsonls = "plugins.lsps_langs.json_lang_config",
    cssls = "plugins.lsps_langs.css_lang_config",
    bashls = "plugins.lsps_langs.bash_lang_config",
    clangd = "plugins.lsps_langs.c_lang_config",
    gopls = "plugins.lsps_langs.go_lang_config"
}

for name_lsp, module_path in pairs(servers_configs) do
    vim.lsp.config(name_lsp, require(module_path))
end

vim.lsp.enable(vim.tbl_keys(servers_configs))
