local bind = require("spencerls.nav.bind")
local util = require("spencerls.nav.util")
local M = {}

local function diag_extreme(first)
	local diags = vim.diagnostic.get(0)
	if #diags == 0 then
		return
	end
	table.sort(diags, function(a, b)
		return a.lnum == b.lnum and (a.col or 0) < (b.col or 0) or a.lnum < b.lnum
	end)
	local d = diags[first and 1 or #diags]
	vim.api.nvim_win_set_cursor(0, { d.lnum, math.max((d.col or 1) - 1, 0) })
	util.center()
end

local function todo_run(first)
	local ok, todo = pcall(require, "todo-comments")
	if not ok then
		return
	end
	if first then
		util.top()
		todo.jump_next()
	else
		util.bottom()
		todo.jump_prev()
	end
	util.center()
end

local function hunk(dir)
	local ok, gs = pcall(require, "gitsigns")
	if ok then
		gs.nav_hunk(dir, { wrap = true })
	end
end

local function diff_step(forward)
	if not vim.wo.diff then
		return
	end
	util.wrap(function()
		vim.cmd.normal({ (forward and "]c" or "[c"), bang = true })
	end, forward and util.top or util.bottom)
end

local function diff_extreme(last)
	if not vim.wo.diff then
		return
	end
	if last then
		util.bottom()
		vim.cmd.normal({ "[c", bang = true })
	end
	if not last then
		util.top()
		vim.cmd.normal({ "]c", bang = true })
	end
	util.center()
end

local function with_todo(fn, reset)
	return function()
		local ok, todo = pcall(require, "todo-comments")
		if ok then
			util.wrap(fn(todo), reset)
		end
	end
end

function M.setup()
	local motions = {
		p = {
			"diagnostic",
			function()
				vim.diagnostic.goto_next({ wrap = true })
				util.center()
			end,
			function()
				vim.diagnostic.goto_prev({ wrap = true })
				util.center()
			end,
			function()
				diag_extreme(false)
			end,
			function()
				diag_extreme(true)
			end,
		},
		t = {
			"todo",
			with_todo(function(t)
				return t.jump_next
			end, util.top),
			with_todo(function(t)
				return t.jump_prev
			end, util.bottom),
			function()
				todo_run(false)
			end,
			function()
				todo_run(true)
			end,
		},
		g = {
			"git hunk",
			function()
				hunk("next")
			end,
			function()
				hunk("prev")
			end,
			function()
				hunk("last")
			end,
			function()
				hunk("first")
			end,
		},
		d = {
			"diff change",
			function()
				diff_step(true)
			end,
			function()
				diff_step(false)
			end,
			function()
				diff_extreme(true)
			end,
			function()
				diff_extreme(false)
			end,
		},
	}

	for letter, cfg in pairs(motions) do
		bind.bind_nav(letter, cfg[1], cfg[2], cfg[3], cfg[4], cfg[5])
	end
end

return M
