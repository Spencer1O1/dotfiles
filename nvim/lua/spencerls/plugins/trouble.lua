local keymap = require("spencerls.keymap")

return {
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			keymap.leader("z", function()
				require("trouble").toggle({ mode = "diagnostics", focus = false })
			end, {
				lazy = true,
				desc = "Trouble diagnostics list",
			}),
		},
		opts = function(_, opts)
			local diag = require("spencerls.nav.diagnostics")

			local function wrap_key(direction)
				return {
					action = function(view, ctx)
						diag.trouble_wrap_action(view, direction, ctx.opts)
					end,
					desc = direction == "next" and "Next item (wrap)" or "Previous item (wrap)",
				}
			end

			opts.keys["}"] = wrap_key("next")
			opts.keys["]]"] = wrap_key("next")
			opts.keys["{"] = wrap_key("prev")
			opts.keys["[["] = wrap_key("prev")
			opts.focus = false

			return opts
		end,
	},
}
