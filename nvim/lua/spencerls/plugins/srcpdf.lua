-- Consumer of srcpdf.nvim. Keymap lives here.
local keymap = require("spencerls.keymap")

return {
	{
		"Spencer1O1/srcpdf.nvim",
		ft = { "tex", "plaintex", "markdown", "html" },
		opts = {},
		keys = {
			keymap.leader("p", function()
				require("srcpdf").open()
			end, {
				lazy = true,
				desc = "Open PDF",
			}),
		},
	},
}
