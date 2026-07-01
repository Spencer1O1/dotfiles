local keymap = require("spencerls.keymap")

return {
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			keymap.leader("g", "<cmd>LazyGit<CR>", {
				lazy = true,
				group = "git",
				desc = "LazyGit",
			}),
			keymap.leader("f", "<cmd>LazyGitFilterCurrentFile<CR>", {
				lazy = true,
				group = "git",
				desc = "LazyGit (current file)",
			}),
		},
	},
}
