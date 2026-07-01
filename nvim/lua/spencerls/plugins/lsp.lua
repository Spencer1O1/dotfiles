local keymap = require("spencerls.keymap")
local nav = require("spencerls.nav")

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
		keys = {
			keymap.leader("i", function()
				vim.lsp.buf.references(nil, { on_list = nav.i.fill })
			end, {
				lazy = true,
				desc = "Gather references",
			}),
			keymap.leader("o", function()
				vim.lsp.buf.document_symbol({ on_list = nav.o.fill })
			end, {
				lazy = true,
				desc = "Gather symbols",
			}),
		},
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
				float = {
					border = "single",
					source = true,
				},
			})

			keymap.leader("P", function()
				local bufnr = vim.api.nvim_get_current_buf()
				if #vim.diagnostic.get(bufnr) == 0 then
					return
				end
				vim.diagnostic.open_float(bufnr, { scope = "line", focus = false })
			end, { desc = "Diagnostics" })

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local bufnr = event.buf

					keymap.set("gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
					keymap.set("gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
					keymap.set("gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to implementation" })
					keymap.set("K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover documentation" })

					keymap.leader("r", vim.lsp.buf.rename, {
						group = "language",
						buffer = bufnr,
						desc = "Rename symbol",
					})
					keymap.leader("a", vim.lsp.buf.code_action, {
						group = "language",
						buffer = bufnr,
						desc = "Code action",
					})
				end,
			})

			vim.lsp.enable(servers)
		end,
	},
}
