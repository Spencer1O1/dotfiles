local keymap = require("spencerls.keymap")

return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},

			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				keymap.leader("j", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
						return
					end

					gitsigns.nav_hunk("next")
				end, {
					group = "git",
					buffer = bufnr,
					desc = "Next git hunk",
				})

				keymap.leader("k", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
						return
					end

					gitsigns.nav_hunk("prev")
				end, {
					group = "git",
					buffer = bufnr,
					desc = "Previous git hunk",
				})

				keymap.leader("s", gitsigns.stage_hunk, {
					group = "git",
					buffer = bufnr,
					desc = "Stage hunk",
				})

				keymap.leader("r", gitsigns.reset_hunk, {
					group = "git",
					buffer = bufnr,
					desc = "Reset hunk",
				})

				keymap.leader("S", gitsigns.stage_buffer, {
					group = "git",
					buffer = bufnr,
					desc = "Stage buffer",
				})

				keymap.leader("R", gitsigns.reset_buffer, {
					group = "git",
					buffer = bufnr,
					desc = "Reset buffer",
				})

				keymap.leader("p", gitsigns.preview_hunk, {
					group = "git",
					buffer = bufnr,
					desc = "Preview hunk",
				})

				keymap.leader("b", function()
					gitsigns.blame_line({ full = true })
				end, {
					group = "git",
					buffer = bufnr,
					desc = "Blame line",
				})

				keymap.leader("d", gitsigns.diffthis, {
					group = "git",
					buffer = bufnr,
					desc = "Diff this",
				})

				keymap.leader("D", function()
					gitsigns.diffthis("~")
				end, {
					group = "git",
					buffer = bufnr,
					desc = "Diff this against previous commit",
				})

				keymap.leader("t", gitsigns.toggle_deleted, {
					group = "git",
					buffer = bufnr,
					desc = "Toggle deleted lines",
				})
			end,
		},
	},
}
