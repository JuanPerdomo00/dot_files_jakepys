local neogit = require("neogit")
neogit.setup({
    integrations = {
        diffview = true
    }
})

vim.keymap.set("n", "<leader>gg", function () neogit.open() end, { desc = "Open Neogit" })
vim.keymap.set("n", "<leader>gc", function () neogit.open({ "commit" }) end, { desc = "Neogit commit" })
vim.keymap.set("n", "<leader>gl", function () neogit.open({ "log" }) end, { desc = "Neogit log" })
