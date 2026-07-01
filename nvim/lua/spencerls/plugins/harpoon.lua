local keymap = require("spencerls.keymap")

return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			keymap.set("<C-e>", function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { lazy = true, desc = "Harpoon menu" }),
			keymap.set("<C-h>", function()
				require("harpoon"):list():select(1)
			end, { lazy = true, desc = "Harpoon file 1" }),
			keymap.set("<C-j>", function()
				require("harpoon"):list():select(2)
			end, { lazy = true, desc = "Harpoon file 2" }),
			keymap.set("<C-k>", function()
				require("harpoon"):list():select(3)
			end, { lazy = true, desc = "Harpoon file 3" }),
			keymap.set("<C-l>", function()
				require("harpoon"):list():select(4)
			end, { lazy = true, desc = "Harpoon file 4" }),
		},
		config = function()
			require("harpoon"):setup()
		end,
	},
}
