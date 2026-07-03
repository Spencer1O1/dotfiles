return {
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		keys = {
			{
				"<leader>zz",
				function()
					require("zen-mode").setup({
						window = { width = 90, options = {} },
						on_close = function()
							vim.wo.wrap = false
							vim.wo.number = true
							vim.wo.rnu = true
							vim.opt.colorcolumn = ""
						end,
					})
					require("zen-mode").toggle()
					vim.wo.wrap = false
					vim.wo.number = true
					vim.wo.rnu = true
				end,
				desc = "Zen mode (90 cols, line numbers)",
			},
			{
				"<leader>zZ",
				function()
					require("zen-mode").setup({
						window = { width = 80, options = {} },
						on_close = function()
							vim.wo.wrap = false
							vim.wo.number = false
							vim.wo.rnu = false
							vim.opt.colorcolumn = "0"
						end,
					})
					require("zen-mode").toggle()
					vim.wo.wrap = false
					vim.wo.number = false
					vim.wo.rnu = false
					vim.opt.colorcolumn = "0"
				end,
				desc = "Zen mode (80 cols, no line numbers)",
			},
		},
	},
}
