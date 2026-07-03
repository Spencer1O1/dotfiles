return {
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = function(_, opts)
			opts = opts or {}
			opts.keys = opts.keys or {}
			opts.focus = false

			local nav = require("spencerls.nav.trouble")

			local function wrap_key(direction)
				return {
					action = function(view, ctx)
						nav.wrap_action(view, direction, ctx.opts)
					end,
					desc = direction == "next" and "Next item (wrap)" or "Previous item (wrap)",
				}
			end

			opts.keys["}"] = wrap_key("next")
			opts.keys["]]"] = wrap_key("next")
			opts.keys["{"] = wrap_key("prev")
			opts.keys["[["] = wrap_key("prev")

			return opts
		end,
	},
}
