--- Fill quickfix on Telescope Enter, then jump to pick.
local nav = require("spencerls.nav")

local M = {}

function M.attach(_, map)
	local action_state = require("telescope.actions.state")
	local action_set = require("telescope.actions.set")
	local from_entry = require("telescope.from_entry")
	local utils = require("telescope.utils")

	local function pick(prompt_bufnr)
		local picker = action_state.get_current_picker(prompt_bufnr)
		if not action_state.get_selected_entry() then
			return
		end
		local entries = {}
		for entry in picker.manager:iter() do
			local text = entry.text or (type(entry.value) == "table" and entry.value.text or entry.value)
			entries[#entries + 1] = {
				bufnr = entry.bufnr,
				filename = from_entry.path(entry, false, false),
				lnum = utils.if_nil(entry.lnum, 1),
				col = utils.if_nil(entry.col, 1),
				text = text,
				type = entry.qf_type,
			}
		end
		nav.i.fill_entries(entries, string.format("%s (%s)", picker.prompt_title, picker:_get_prompt()))
		action_set.select(prompt_bufnr, "default")
	end

	map("i", "<CR>", pick)
	map("n", "<CR>", pick)
	return true
end

return M
