return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("nvim-tree").setup({
			disable_netrw = true,
			hijack_netrw = true,

			filters = {
				dotfiles = false,
				git_ignored = false,
			},

			view = {
				width = 35,
				side = "left",
			},

			renderer = {
				group_empty = true,
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = true,
					},
				},
			},
		})
	end,
}
