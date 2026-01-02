return {
	"goolord/alpha-nvim",
	-- dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local startify = require("alpha.themes.startify")

		startify.section.header.val = {
			"     ██╗ █████╗ ██╗  ██╗███████╗██████╗ ██╗   ██╗███████╗███╗   ██╗██╗   ██╗██╗███╗   ███╗    ",
			"     ██║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗╚██╗ ██╔╝██╔════╝████╗  ██║██║   ██║██║████╗ ████║    ",
			"     ██║███████║█████╔╝ █████╗  ██████╔╝ ╚████╔╝ ███████╗██╔██╗ ██║██║   ██║██║██╔████╔██║    ",
			"██   ██║██╔══██║██╔═██╗ ██╔══╝  ██╔═══╝   ╚██╔╝  ╚════██║██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║    ",
			"╚█████╔╝██║  ██║██║  ██╗███████╗██║        ██║   ███████║██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║    ",
			" ╚════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝        ╚═╝   ╚══════╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝    ",
			"                                                                                              ",
			"With God by your side, no fear can stop you, and no dream is too big. Trust,",
			"move forward, and never doubt He walks with you.",
		}

		startify.file_icons.provider = "devicons"
		startify.section.top_buttons.val = {
			startify.button("e", "  New file", ":ene <CR>"),
			startify.button("SPC f f", "󰈞  Find file", ":Telescope find_files<CR>"),
			startify.button("SPC f h", "  Recently opened files", ":Telescope oldfiles<CR>"),
			startify.button("SPC f r", "󰃃  Frecency/MRU", ":Telescope frecency<CR>"),
			startify.button("SPC f g", "  Find word", ":Telescope live_grep<CR>"),
			startify.button("SPC f m", "  Jump to bookmarks", ":Telescope marks<CR>"),
			startify.button("SPC s l", "󰑤  Open last session", ":SessionLoad<CR>"),
		}
		require("alpha").setup(startify.config)
	end,
}
