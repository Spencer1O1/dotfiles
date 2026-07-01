local keymap = require("spencerls.keymap")
local nav_telescope = require("spencerls.nav.telescope")

local function builtin()
	return require("telescope.builtin")
end

return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			keymap.leader("f", function()
				builtin().find_files()
			end, { lazy = true, desc = "Find files" }),
			keymap.leader("/", function()
				builtin().live_grep()
			end, { lazy = true, desc = "Fuzzy grep" }),
			keymap.leader("b", function()
				builtin().buffers()
			end, { lazy = true, desc = "Find buffers" }),
			keymap.leader("?", function()
				builtin().help_tags()
			end, { lazy = true, desc = "Help" }),
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
