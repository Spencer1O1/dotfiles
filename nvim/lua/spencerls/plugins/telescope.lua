local keymap = require("spencerls.keymap")
local nav_telescope = require("spencerls.nav.telescope")
local builtin = require("telescope.builtin")

return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			keymap.leader("f", builtin.find_files, { lazy = true, desc = "Find files" }),
			keymap.leader("/", builtin.live_grep, { lazy = true, desc = "Live grep" }),
			keymap.leader("b", builtin.buffers, { lazy = true, desc = "Find buffers" }),
			keymap.leader("h", builtin.help_tags, { lazy = true, desc = "Help tags" }),
		},
		opts = {
			defaults = {
				attach_mappings = nav_telescope.attach,
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
					},
				},
			},
		},
	},
}
