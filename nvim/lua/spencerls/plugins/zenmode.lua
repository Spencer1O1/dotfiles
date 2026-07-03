return {
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		keys = {
			{
				"<leader>zz",
				function()
					require("zen-mode").toggle({
						window = {
							width = 80,
							options = {
								foldcolumn = "0",
								number = true,
								relativenumber = true,
								colorcolumn = "0",
							},
						},
						on_close = function()
							vim.schedule(function()
								vim.wo.wrap = false
								vim.wo.number = true
								vim.wo.relativenumber = true
								vim.wo.foldcolumn = "1"
								vim.wo.colorcolumn = "80"
							end)
						end,
					})
				end,
				desc = "Zen mode",
			},
			{
				"<leader>zZ",
				function()
					require("zen-mode").toggle({
						window = {
							width = 80,
							options = {
								foldcolumn = "0",
								number = false,
								relativenumber = false,
								colorcolumn = "0",
							},
						},
						on_close = function()
							vim.schedule(function()
								vim.wo.wrap = false
								vim.wo.number = true
								vim.wo.relativenumber = true
								vim.wo.foldcolumn = "1"
								vim.wo.colorcolumn = "80"
							end)
						end,
					})
				end,
				desc = "Zen mode (no line numbers)",
			},
		},
	},
}
