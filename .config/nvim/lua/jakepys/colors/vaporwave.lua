require("tokyonight").setup({
    style = "night",
    styles = {
        comments  = { italic = true },
        keywords  = { bold = true },
        functions = {}
    },
    transparent = false,
    on_colors = function (c)
        c.bg = "#120a24"
        c.bg_dark = "#0b0618"
        c.bg_float = "#1a1236"
        c.bg_popup = "#1a1236"
        c.bg_sidebar = "#0b0618"
        c.bg_statusline = "#1a1236"
        c.bg_highlight = "#1a1236"
        c.bg_visual = "#3a2a70"
        c.border = "#4a2c82"
        c.fg = "#e8d8ff"
        c.fg_dark = "#b3a0dc"
        c.fg_gutter = "#4a2c82"
        c.comment = "#9a84c9"
        c.blue = "#8a97ff"
        c.cyan = "#8ff0d8"
        c.green = "#a8f0a0"
        c.magenta = "#ff6ec7"
        c.purple = "#c04df0"
        c.orange = "#ff8a30"
        c.red = "#e5384f"
        c.yellow = "#ffc857"
        c.teal = "#8ff0d8"
    end
})

vim.cmd.colorscheme("tokyonight")
