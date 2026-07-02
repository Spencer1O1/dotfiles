local function codeium_has_suggestion()
	local ok, status = pcall(require("codeium.virtual_text").status)
	if not ok then
		return false
	end
	return status.state == "completions" and status.total > 0
end

-- Codeium accept() returns an expr-mapping key string. blink.cmp keymaps also use
-- expr but with replace_keycodes=false, so returning that string pastes it literally.
local function accept_codeium()
	if not codeium_has_suggestion() then
		return false
	end

	local keys = require("codeium.virtual_text").accept()
	if type(keys) ~= "string" or keys == "" then
		return false
	end

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
	return true
end

return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		opts = {
			keymap = {
				preset = "none",
				["<C-.>"] = {
					function(cmp)
						if cmp.is_menu_visible() then
							return cmp.hide()
						end

						return cmp.show({ providers = { "lsp", "path", "snippets" } })
					end,
				},

				["<Tab>"] = {
					function(cmp)
						if cmp.is_menu_visible() then
							return cmp.select_next()
						end
						if accept_codeium() then
							return true
						end
					end,
					"snippet_forward",
					"fallback",
				},
				["<S-Tab>"] = {
					function(cmp)
						if cmp.is_menu_visible() then
							return cmp.select_prev()
						end
					end,
					"snippet_backward",
					"fallback",
				},

				["<C-f>"] = {
					function()
						if accept_codeium() then
							return true
						end
					end,
				},

				["<CR>"] = {
					function(cmp)
						if cmp.is_menu_visible() then
							return cmp.accept()
						end
					end,
					"fallback_to_mappings",
				},
			},
			appearance = {
				nerd_font_variant = "mono",
			},

			completion = {
				trigger = {
					prefetch_on_insert = false,
					show_on_keyword = false,
					show_on_trigger_character = false,
					show_on_insert = false,
				},

				menu = {
					auto_show = false,
				},

				ghost_text = {
					enabled = false,
				},

				documentation = {
					auto_show = false,
				},
			},

			sources = {
				default = { "lsp", "path", "snippets" },
			},

			fuzzy = {
				implementation = "prefer_rust_with_warning",
			},
		},
		opts_extend = { "sources.default" },
	},
}
