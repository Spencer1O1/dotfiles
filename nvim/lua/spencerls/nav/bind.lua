local keymap = require("spencerls.keymap")
local M = {}

function M.clear_defaults()
	for _, l in ipairs({ "a", "b", "l", "q", "T", "D" }) do
		for _, pre in ipairs({ "]", "[" }) do
			pcall(vim.keymap.del, "n", pre .. l)
			if #l == 1 then
				pcall(vim.keymap.del, "n", pre .. l:upper())
			end
		end
	end
end

function M.bind_nav(letter, label, next_fn, prev_fn, last_fn, first_fn)
	local cap = letter:upper()
	keymap.set("]" .. letter, next_fn, { desc = "Next " .. label })
	keymap.set("[" .. letter, prev_fn, { desc = "Previous " .. label })
	keymap.set("]" .. cap, last_fn, { desc = "Last " .. label })
	keymap.set("[" .. cap, first_fn, { desc = "First " .. label })
end

return M
