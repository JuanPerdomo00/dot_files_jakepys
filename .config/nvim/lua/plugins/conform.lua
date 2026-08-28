require("conform").setup({
    formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
        python = { "ruff_format" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" }
    }
})
