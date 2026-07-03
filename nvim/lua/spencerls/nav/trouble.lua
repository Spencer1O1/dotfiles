local util = require("spencerls.nav.util")

local M = {}

local OPEN_OPTS = { focus = false, refresh = false }
local HUB_MODES = { diagnostics = true, qflist = true, loclist = true }

local function with_trouble(fn)
	local ok, trouble = pcall(require, "trouble")
	if ok then
		fn(trouble)
	end
end

local function open_hub_view(mode)
	local ok, View = pcall(require, "trouble.view")
	if not ok then
		return nil
	end
	local filter = { open = true }
	if mode then
		filter.mode = mode
	end
	for _, entry in ipairs(View.get(filter)) do
		if HUB_MODES[entry.mode] then
			return entry.view
		end
	end
	return nil
end

function M.is_open(opts)
	if type(opts) == "string" then
		opts = { mode = opts }
	end
	return open_hub_view(opts.mode) ~= nil
end

function M.set_mode(view, mode)
	local Config = require("trouble.config")
	local Spec = require("trouble.spec")
	local Section = require("trouble.view.section")

	for _, section in ipairs(view.sections) do
		section:stop()
	end

	view._filters = {}
	view.opts = vim.tbl_deep_extend("force", view.opts, Config.get({
		mode = mode,
		focus = false,
	}))

	view.sections = {}
	for _, s in ipairs(Spec.sections(view.opts)) do
		local section = Section.new(s, view.opts)
		section.on_update = function()
			view:update()
		end
		table.insert(view.sections, section)
	end

	view:listen()

	if view.win:valid() then
		local w = vim.w[view.win.win]
		if w.trouble then
			w.trouble.mode = mode
		end
	end

	view:refresh({ opening = false }):next(function()
		view:update()
	end)
end

function M.toggle(opts)
	if type(opts) == "string" then
		opts = { mode = opts }
	end
	opts = vim.tbl_extend("force", { focus = false }, opts or {})
	local mode = opts.mode
	if not mode then
		return
	end

	with_trouble(function(tr)
		local open = open_hub_view()
		if open then
			if open.opts.mode == mode then
				open:close()
			else
				M.set_mode(open, mode)
			end
			return
		end
		tr.open(opts)
	end)
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
