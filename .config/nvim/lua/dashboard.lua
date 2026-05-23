local startify = require("alpha.themes.startify")

startify.section.header.val = {
    " _______________________________________",
    "/ There's nothing better than gnu/linux \\",
    "\\ and nvim as your ally                 /",
    " --------------------------------------- ",
    "        \\   ^__^",
    "         \\  (oo)\\________",
    "            (__)\\ Jakepys)\\/\\",
    "                ||----w |",
    "                ||     ||",
    "",
    "    [b] New Buffer        [0] Config",
}

startify.file_icons.provider = "mini"

startify.section.top_buttons.val = {
    startify.button("SPC f f", "󰈞  Find file", ":lua MiniPick.builtin.files()<CR>"),
    startify.button("SPC f h", "  Recently opened files", ":lua MiniExtra.pickers.oldfiles()<CR>"),
    startify.button("SPC f g", "  Find word", ":lua MiniPick.builtin.grep_live()<CR>"),
    startify.button("SPC f m", "  Jump to bookmarks", ":lua MiniExtra.pickers.marks()<CR>"),
}

startify.section.footer.val = {
    startify.button("b", "New Buffer", ":enew<CR>"),
    startify.button("0", "Config", ":e ~/.config/nvim/init.lua<CR>"),
}

require("alpha").setup(startify.config)
