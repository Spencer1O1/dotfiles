local brackets = require("spencerls.pairs.brackets")
local keymap = require("spencerls.keymap")
local tags = require("spencerls.pairs.tags")
local util = require("spencerls.pairs.util")

require("spencerls.pairs.rename")

local function collapse_multiline()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local cur = vim.api.nvim_get_current_line()
	if cur:find("%S") or row < 2 then
		return false
	end
	if row >= vim.api.nvim_buf_line_count(0) then
		return false
	end
	local prev = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
	local nxt = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
	if not prev or not nxt then
		return false
	end

	local closers = { ["("] = "%)", ["["] = "%]", ["{"] = "}" }
	local last = prev:match("([%(%[{])%s*$")
	local ok = last and nxt:match("^%s*" .. closers[last] .. "%s*$")

	if not ok then
		local opening = tags.opening_at_end(prev)
		if opening == "" or opening:find("/>%s*$") then
			return false
		end
		local tag = tags.tag_name(opening)
		local icase = vim.bo.filetype == "xml" and [[\C]] or [[\c]]
		local closing = vim.fn.matchstr(nxt, icase .. [[^\s*</]] .. vim.fn.escape(tag, [[\]]) .. [[\s*>\s*$]])
		if closing == "" then
			return false
		end
	end

	local prev_r = prev:gsub("%s+$", "")
	local next_l = nxt:match("^%s*(.-)%s*$")
	local buf = vim.api.nvim_get_current_buf()
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		vim.api.nvim_buf_set_lines(buf, row - 2, row + 1, false, { prev_r .. next_l })
		if vim.api.nvim_get_current_buf() == buf then
			vim.api.nvim_win_set_cursor(0, { row - 1, #prev_r })
		end
	end)
	return true
end

local function backspace()
	if collapse_multiline() then
		return ""
	end
	local pair = util.char_before() .. util.char_after()
	if pair == "()" or pair == "[]" or pair == "{}" or pair == '""' or pair == "''" then
		return "<BS><Del>"
	end
	local open_w, close_w = tags.matching_widths()
	if open_w then
		return string.rep("<BS>", open_w) .. string.rep("<Del>", close_w)
	end
	return "<BS>"
end

local function smart_enter()
	if brackets.is_pair() or tags.is_pair() then
		return util.structural_newline()
	end
	return "<CR>"
end

local M = {}

function M.enter()
	return smart_enter()
end

local insert = { mode = "i", expr = true, silent = true }

keymap.set("(", function()
	return brackets.open("(", ")")
end, vim.tbl_extend("force", insert, { desc = "Pair (" }))

keymap.set("[", function()
	return brackets.open("[", "]")
end, vim.tbl_extend("force", insert, { desc = "Pair [" }))

keymap.set("{", function()
	return brackets.open("{", "}")
end, vim.tbl_extend("force", insert, { desc = "Pair {" }))

keymap.set(")", function()
	return brackets.close(")")
end, vim.tbl_extend("force", insert, { desc = "Step over )" }))

keymap.set("]", function()
	return brackets.close("]")
end, vim.tbl_extend("force", insert, { desc = "Step over ]" }))

keymap.set("}", function()
	return brackets.close("}")
end, vim.tbl_extend("force", insert, { desc = "Step over }" }))

keymap.set('"', function()
	return brackets.quote('"')
end, vim.tbl_extend("force", insert, { desc = "Pair quote" }))

keymap.set("'", function()
	return brackets.quote("'")
end, vim.tbl_extend("force", insert, { desc = "Pair '" }))

keymap.set("<BS>", backspace, vim.tbl_extend("force", insert, { desc = "Delete pair" }))
keymap.set(">", tags.close, vim.tbl_extend("force", insert, { desc = "Close tag" }))
keymap.set("<CR>", smart_enter, vim.tbl_extend("force", insert, { desc = "Expand pair" }))

return M
