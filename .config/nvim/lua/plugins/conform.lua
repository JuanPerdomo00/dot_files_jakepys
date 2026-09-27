require("conform").setup({
    formatters = {
        nph = {
            command = "nph",
            args = { "-" },
            stdin = true
        },
        schemat = {
            command = "schemat"
        }
    },
    formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
        python = { "ruff_format" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        nim = { "nph" },
        scheme = { "schemat" }
    }
})
