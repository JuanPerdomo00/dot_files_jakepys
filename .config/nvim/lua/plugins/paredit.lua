local paredit = require("nvim-paredit")

paredit.setup({
    filetypes = { "scheme" },

    use_default_keys = true,

    cursor_behaviour = "auto",

    dragging = {
        auto_drag_pairs = true
    },

    indent = {
        enabled = false
    },

    languages = {
        scheme = {
            whitespace_chars = { " ", "," }
        }
    }
})

vim.keymap.set("n", "<leader>ps", paredit.unwrap.unwrap_form_under_cursor, {
    desc = "Paredit splice"
})

vim.keymap.set("n", ">)", paredit.api.slurp_forwards, {
    desc = "Paredit slurp forwards"
})

vim.keymap.set("n", "><", paredit.api.barf_backwards, {
    desc = "Paredit barf backwards"
})

vim.keymap.set("n", ")<", paredit.api.barf_forwards, {
    desc = "Paredit barf forwards"
})

vim.keymap.set("n", "(<", paredit.api.slurp_backwards, {
    desc = "Paredit slurp backwards"
})

vim.keymap.set("n", ">e", paredit.api.drag_element_forwards, {
    desc = "Paredit drag element forwards"
})

vim.keymap.set("n", "<e", paredit.api.drag_element_backwards, {
    desc = "Paredit drag element backwards"
})

vim.keymap.set("n", ">f", paredit.api.drag_form_forwards, {
    desc = "Paredit drag form forwards"
})

vim.keymap.set("n", "<f", paredit.api.drag_form_backwards, {
    desc = "Paredit drag form backwards"
})

vim.keymap.set("n", "<leader>po", paredit.api.raise_form, {
    desc = "Paredit raise form"
})

vim.keymap.set("n", "<leader>pO", paredit.api.raise_element, {
    desc = "Paredit raise element"
})
