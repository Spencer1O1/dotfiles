-- Consumer of srcpdf.nvim (plugin lives in ~/nvim-pdf). Keymap lives here.
local keymap = require("spencerls.keymap")

return {
	{
		dir = vim.fn.expand("~/nvim-pdf"),
		name = "srcpdf.nvim",
		ft = { "tex", "plaintex" },
		opts = {},
		keys = {
			keymap.leader("p", function()
				require("srcpdf").open()
			end, {
				lazy = true,
				desc = "Open sibling PDF",
			}),
		},
	},
}
