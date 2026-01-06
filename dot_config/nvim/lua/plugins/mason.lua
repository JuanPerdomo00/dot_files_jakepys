return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					border = "rounded",
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"pyright",
					"rust_analyzer",
					"ts_ls",
					"html",
					"cssls",
					"dockerls",
					"clangd",
					"zls",
					"jsonls",
					"bashls",
				},
				automatic_installation = false,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if has_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("user_lspconfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf, noremap = true, silent = true }

					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gk", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<C-f>", function()
						vim.lsp.buf.format({ async = true })
					end, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<leader>lh", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
					vim.keymap.set("n", "<leader>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, opts)
					vim.keymap.set("n", "<leader>d", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "<leader>p", function()
						vim.lsp.buf.format({ async = true })
					end, opts)
					vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
					vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
				end,
			})

			local default_config = {
				capabilities = capabilities,
			}

			local function get_server_config(server_name)
				local ok, config = pcall(require, "lsp-servers." .. server_name)
				return ok and config or {}
			end

			local servers = {
				lua_ls = vim.tbl_extend("force", default_config, get_server_config("lua_ls")),
				pyright = vim.tbl_extend("force", default_config, get_server_config("pyright")),
				rust_analyzer = vim.tbl_extend("force", default_config, get_server_config("rust_analyzer")),
				ts_ls = vim.tbl_extend("force", default_config, get_server_config("ts_ls")),
				html = vim.tbl_extend("force", default_config, get_server_config("html")),
				cssls = vim.tbl_extend("force", default_config, get_server_config("cssls")),
				dockerls = vim.tbl_extend("force", default_config, get_server_config("dockerls")),
				clangd = vim.tbl_extend("force", default_config, get_server_config("clangd")),
				zls = vim.tbl_extend("force", default_config, get_server_config("zls")),
				jsonls = vim.tbl_extend("force", default_config, get_server_config("jsonls")),
				bashls = vim.tbl_extend("force", default_config, get_server_config("bashls")),
			}

			for name, config in pairs(servers) do
				vim.lsp.config(name, config)
			end

			vim.lsp.enable(vim.tbl_keys(servers))

			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			})

			local signs = {
				{ name = "DiagnosticSignError", text = "" },
				{ name = "DiagnosticSignWarn", text = " " },
				{ name = "DiagnosticSignHint", text = "󰌵" },
				{ name = "DiagnosticSignInfo", text = "" },
			}

			for _, sign in ipairs(signs) do
				vim.fn.sign_define(sign.name, {
					texthl = sign.name,
					text = sign.text,
					numhl = "",
				})
			end
		end,
	},
}
