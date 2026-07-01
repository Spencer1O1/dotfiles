local keymap = require("spencerls.keymap")

local servers = {
	"lua_ls",
	"ts_ls",
	"html",
	"cssls",
	"jsonls",
	"bashls",
	"pyright",
	"clangd",
	"rust_analyzer",
	"gopls",
	"phpactor",
	"tailwindcss",
}

return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},

	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = servers,
			automatic_enable = false,
		},
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})

			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local bufnr = event.buf

					keymap.map("gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
					keymap.map("gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
					keymap.map("gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to implementation" })
					keymap.map("gr", vim.lsp.buf.references, { buffer = bufnr, desc = "Go to references" })
					keymap.map("K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover documentation" })

					keymap.leader(
						"r",
						vim.lsp.buf.rename,
						{ buffer = bufnr, group = "language", desc = "Rename symbol" }
					)
					keymap.leader(
						"a",
						vim.lsp.buf.code_action,
						{ buffer = bufnr, group = "language", desc = "Code action" }
					)
					keymap.leader(
						"d",
						vim.diagnostic.open_float,
						{ buffer = bufnr, group = "diagnostics", desc = "Open diagnostic" }
					)
					keymap.leader(
						"k",
						vim.diagnostic.goto_prev,
						{ buffer = bufnr, group = "diagnostics", desc = "Previous diagnostic" }
					)
					keymap.leader(
						"j",
						vim.diagnostic.goto_next,
						{ buffer = bufnr, group = "diagnostics", desc = "Next diagnostic" }
					)
				end,
			})

			vim.lsp.enable(servers)
		end,
	},
}
