local keymap = require("spencerls.keymap")

local letters = { "i", "I", "o", "O", "p", "P", "t", "T", "g", "G", "d", "D" }
local nav_bracket = {}
for _, letter in ipairs(letters) do
	nav_bracket[letter] = true
end

return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			spec = vim.list_extend(keymap.which_key_spec(), {
				{ "]", group = "next" },
				{ "[", group = "prev" },
			}),
			filter = function(mapping)
				local lhs = mapping.lhs or ""
				if not lhs:match("^[%[%]]") then
					return true
				end
				local letter = lhs:match("^[%[%]](.)$")
				return letter ~= nil and nav_bracket[letter] == true
			end,
		},
	},
}
