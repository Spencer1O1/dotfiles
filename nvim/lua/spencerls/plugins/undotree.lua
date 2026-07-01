local keymap = require("spencerls.keymap")

return {
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		init = function()
			vim.g.undotree_SetFocusWhenToggle = 1
		end,
		keys = {
			keymap.leader("u", "<cmd>UndotreeToggle<CR>", {
				lazy = true,
				desc = "Undotree",
			}),
		},
	},
}
