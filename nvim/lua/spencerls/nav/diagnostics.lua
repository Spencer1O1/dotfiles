local bind = require("spencerls.nav.bind")
local util = require("spencerls.nav.util")

local M = {}

local TROUBLE_MODE = "diagnostics"

local function trouble_open()
	local ok, trouble = pcall(require, "trouble")
	return ok and trouble.is_open(TROUBLE_MODE)
end

local function with_trouble(fn)
	local ok, trouble = pcall(require, "trouble")
	if ok then
		fn(trouble)
	end
end

local function trouble_item_buf(item)
	if item.buf and item.buf > 0 then
		return item.buf
	end
	return vim.fn.bufnr(item.filename, false)
end

local function trouble_item_index(items)
	local bufnr = vim.api.nvim_get_current_buf()
	local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))

	for i, item in ipairs(items) do
		if trouble_item_buf(item) == bufnr and item.pos[1] == lnum and item.pos[2] == col then
			return i
		end
	end

	local best_idx, best_score
	for i, item in ipairs(items) do
		if trouble_item_buf(item) == bufnr then
			local score = item.pos[1] * 100000 + item.pos[2]
			local cursor_score = lnum * 100000 + col
			if score <= cursor_score and (not best_score or score > best_score) then
				best_score = score
				best_idx = i
			end
		end
	end

	return best_idx or 1
end

local function trouble_jump_wrapped(direction)
	with_trouble(function(trouble)
		local mode_opts = { mode = TROUBLE_MODE, focus = false, refresh = false }
		local items = trouble.get_items(mode_opts)
		if #items == 0 then
			return
		end

		local view = trouble.open(mode_opts)
		if not view then
			return
		end

		if direction == "first" then
			view:move({ idx = 1, jump = true })
		elseif direction == "last" then
			view:move({ idx = -1, jump = true })
		else
			local idx = trouble_item_index(items)
			if direction == "next" then
				idx = idx >= #items and 1 or idx + 1
			else
				idx = idx <= 1 and #items or idx - 1
			end
			view:move({ idx = idx, jump = true })
		end

		util.center()
	end)
end

--- Wrap next/prev inside the trouble panel (used by trouble.nvim keymaps).
function M.trouble_wrap_action(view, direction, action_opts)
	action_opts = action_opts or {}
	local jump = action_opts.jump
	local count = vim.v.count1

	if direction == "next" then
		for _ = 1, count do
			local before = vim.api.nvim_win_get_cursor(view.win.win)[1]
			view:move({ down = 1, jump = jump })
			local after = vim.api.nvim_win_get_cursor(view.win.win)[1]
			if after == before then
				view:move({ idx = 1, jump = jump })
			end
		end
	elseif direction == "prev" then
		for _ = 1, count do
			local before = vim.api.nvim_win_get_cursor(view.win.win)[1]
			view:move({ up = 1, jump = jump })
			local after = vim.api.nvim_win_get_cursor(view.win.win)[1]
			if after == before then
				view:move({ idx = -1, jump = jump })
			end
		end
	end
end

local function buffer_extreme(first)
	local diags = vim.diagnostic.get(0)
	if #diags == 0 then
		return
	end
	table.sort(diags, function(a, b)
		return a.lnum == b.lnum and (a.col or 0) < (b.col or 0) or a.lnum < b.lnum
	end)
	local d = diags[first and 1 or #diags]
	vim.api.nvim_win_set_cursor(0, { d.lnum, math.max(d.col or 0, 0) })
	util.center()
end

local function buffer_jump(count)
	local diag = vim.diagnostic.jump({ count = count, wrap = true, bufnr = 0 })
	if diag then
		util.center()
	end
end

local function jump(direction)
	if trouble_open() then
		trouble_jump_wrapped(direction)
		return
	end

	if direction == "next" then
		buffer_jump(1)
	elseif direction == "prev" then
		buffer_jump(-1)
	elseif direction == "last" then
		buffer_extreme(false)
	else
		buffer_extreme(true)
	end
end

function M.setup()
	bind.bind_nav(
		"z",
		"diagnostic",
		function()
			jump("next")
		end,
		function()
			jump("prev")
		end,
		function()
			jump("last")
		end,
		function()
			jump("first")
		end
	)
end

return M
