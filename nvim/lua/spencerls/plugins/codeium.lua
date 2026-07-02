return {
	{
		"Exafunction/windsurf.nvim",
		event = "InsertEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("codeium").setup({
				enable_cmp_source = false,
				enable_chat = false,
				quiet = true,
				virtual_text = {
					enabled = true,
					manual = false,
					idle_delay = 150,
					map_keys = false,
				},
			})

			-- Neovim buffers are always LF; Codeium defaults to CRLF on Windows (fileformat=dos)
			-- and inserts literal ^M when accepting multi-line completions.
			local util = require("codeium.util")
			util.get_newline = function(_)
				return "\n"
			end

			local virtual_text = require("codeium.virtual_text")
			local get_completion_text = virtual_text.get_completion_text
			virtual_text.get_completion_text = function()
				return get_completion_text():gsub("\r", "")
			end
		end,
	},
}
