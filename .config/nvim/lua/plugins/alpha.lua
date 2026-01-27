return {
	"goolord/alpha-nvim",
	config = function()
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




		startify.file_icons.provider = "devicons"
		startify.section.top_buttons.val = {
			startify.button("SPC f f", "󰈞  Find file", ":Telescope find_files<CR>"),
			startify.button("SPC f h", "  Recently opened files", ":Telescope oldfiles<CR>"),
			startify.button("SPC f r", "󰃃  Frecency/MRU", ":Telescope frecency<CR>"),
			startify.button("SPC f g", "  Find word", ":Telescope live_grep<CR>"),
			startify.button("SPC f m", "  Jump to bookmarks", ":Telescope marks<CR>"),
			startify.button("SPC s l", "󰑤  Open last session", ":SessionLoad<CR>"),
		}


		startify.section.footer.val = {
			startify.button("b", "New Buffer", ":enew<CR>"),
			startify.button("0", "Config", ":e ~/.config/nvim/init.lua<CR>")
		}
		require("alpha").setup(startify.config)
	end,
}
