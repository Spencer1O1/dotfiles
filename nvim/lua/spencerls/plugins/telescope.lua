local keymap = require("spencerls.keymap")

return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			keymap.lazy_leader("f", function()
				require("telescope.builtin").find_files()
			end, {
				desc = "Find files",
			}),
			keymap.lazy_leader("/", function()
				require("telescope.builtin").live_grep()
			end, {
				desc = "Live grep",
			}),
			keymap.lazy_leader("b", function()
				require("telescope.builtin").buffers()
			end, {
				desc = "Find buffers",
			}),
			keymap.lazy_leader("h", function()
				require("telescope.builtin").help_tags()
			end, {
				desc = "Help",
			}),
			keymap.lazy_leader("/", function()
				require("telescope.builtin").diagnostics()
			end, {
				group = "diagnostics",
				desc = "Find diagnostics",
			}),
			keymap.lazy_leader("r", function()
				require("telescope.builtin").lsp_references()
			end, {
				group = "language",
				desc = "Find references",
			}),
			keymap.lazy_leader("s", function()
				require("telescope.builtin").lsp_document_symbols()
			end, {
				group = "language",
				desc = "Find symbols",
			}),
		},
		opts = {
			defaults = {
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
						["<C-q>"] = "send_selected_to_qflist",
					},
				},
			},
		},
	},
}
