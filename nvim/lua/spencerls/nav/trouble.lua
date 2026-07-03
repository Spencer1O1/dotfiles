local util = require("spencerls.nav.util")

local M = {}

local OPEN_OPTS = { focus = false, refresh = false }

function M.is_open(opts)
	local ok, trouble = pcall(require, "trouble")
	if not ok then
		return false
	end
	if type(opts) == "string" then
		opts = { mode = opts }
	end
	return trouble.is_open(opts)
end

local function with_trouble(fn)
	local ok, trouble = pcall(require, "trouble")
	if ok then
		fn(trouble)
	end
end

local function item_buf(item)
	if item.buf and item.buf > 0 then
		return item.buf
	end
	return vim.fn.bufnr(item.filename, false)
end

local function item_index(items)
	local bufnr = vim.api.nvim_get_current_buf()
	local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))

	for i, item in ipairs(items) do
		if item_buf(item) == bufnr and item.pos[1] == lnum and item.pos[2] == col then
			return i
		end
	end

	local best_idx, best_score
	for i, item in ipairs(items) do
		if item_buf(item) == bufnr then
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

function M.jump_mode(direction, mode)
	with_trouble(function(trouble)
		local mode_opts = vim.tbl_extend("force", OPEN_OPTS, { mode = mode })
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
			local idx = item_index(items)
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

function M.wrap_action(view, direction, action_opts)
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

return M
