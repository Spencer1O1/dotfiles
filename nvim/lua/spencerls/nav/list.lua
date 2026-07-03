local keymap = require("spencerls.keymap")
local bind = require("spencerls.nav.bind")
local util = require("spencerls.nav.util")
local trouble = require("spencerls.nav.trouble")
local M = {}

local function anchor_index(items)
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local index = 1
	for i, item in ipairs(items) do
		if (item.lnum or 1) <= line then
			index = i
		else
			break
		end
	end
	return index
end

local function jump_item(item)
	if item.bufnr and item.bufnr > 0 and vim.api.nvim_buf_is_valid(item.bufnr) then
		vim.api.nvim_set_current_buf(item.bufnr)
	elseif item.filename and item.filename ~= "" then
		vim.cmd("keepjumps edit " .. vim.fn.fnameescape(item.filename))
	end
	pcall(vim.api.nvim_win_set_cursor, 0, {
		item.lnum or 1,
		math.max((item.col or 1) - 1, 0),
	})
	util.center()
end

local function make_kind(loc)
	if loc then
		return {
			get = function()
				return vim.fn.getloclist(0)
			end,
			idx = function()
				return vim.fn.getloclist(0, { idx = 0 }).idx
			end,
			set = function(w)
				vim.fn.setloclist(0, {}, " ", w)
			end,
			set_idx = function(i)
				vim.fn.setloclist(0, {}, "a", { idx = i })
			end,
			next = "lnext",
			prev = "lprev",
			wn = "lfirst",
			wp = "llast",
			close = "lclose",
			loclist = 1,
		}
	end
	return {
		get = vim.fn.getqflist,
		idx = function()
			return vim.fn.getqflist({ idx = 0 }).idx
		end,
		set = function(w)
			vim.fn.setqflist({}, " ", w)
		end,
		set_idx = function(i)
			vim.fn.setqflist({}, "a", { idx = i })
		end,
		next = "cnext",
		prev = "cprev",
		wn = "cfirst",
		wp = "clast",
		close = "cclose",
		loclist = 0,
	}
end

local function jump_list(kind, index)
	local item = kind.get()[index]
	if not item then
		return
	end
	kind.set_idx(index)
	jump_item(item)
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

---@param letter string
---@param kind boolean|string false = qflist, true = loclist, string = trouble mode (e.g. "diagnostics")
---@param label string
---@param hubs table
function M.setup(letter, kind, label, hubs)
	local is_diag = type(kind) == "string"
	local k = is_diag and nil or make_kind(kind)
	local trouble_mode = is_diag and kind or (kind and "loclist" or "qflist")
	local pending = false
	local H = {}

	function H.fill(what)
		if is_diag or #what.items == 0 then
			return
		end
		k.set(what)
		k.set_idx(anchor_index(what.items))
		pending = true
	end

	function H.clear_pending()
		pending = false
	end

	function H.fill_entries(entries, title)
		if is_diag then
			return
		end
		vim.api.nvim_exec_autocmds("QuickFixCmdPre", {})
		vim.fn.setqflist(entries, " ")
		if title then
			vim.fn.setqflist({}, "a", { title = title })
		end
		vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
		pending = false
	end

	local function empty()
		if is_diag then
			return #vim.diagnostic.get(0) == 0
		end
		return #k.get() == 0
	end

	local function jump(direction)
		if trouble.is_open(trouble_mode) then
			trouble.jump_mode(direction, trouble_mode)
			return
		end
		if is_diag then
			if direction == "next" then
				buffer_jump(1)
			elseif direction == "prev" then
				buffer_jump(-1)
			elseif direction == "last" then
				buffer_extreme(false)
			else
				buffer_extreme(true)
			end
			return
		end
		if empty() then
			return
		end
		if pending then
			pending = false
			jump_list(k, k.idx())
			return
		end
		if direction == "next" then
			util.cmd_wrap(k.next, k.wn)
		elseif direction == "prev" then
			util.cmd_wrap(k.prev, k.wp)
		elseif direction == "last" then
			jump_list(k, #k.get())
		else
			jump_list(k, 1)
		end
	end

	bind.bind_nav(letter, label, function()
		jump("next")
	end, function()
		jump("prev")
	end, function()
		jump("last")
	end, function()
		jump("first")
	end)

	keymap.leader(letter:upper(), function()
		if not is_diag and kind and empty() then
			return
		end
		trouble.toggle(trouble_mode)
	end, { desc = "Toggle " .. label .. " list" })

	if not is_diag then
		hubs[kind and "loc" or "qf"] = H
	end
	return H
end

function M.setup_qf_autocmd(hubs)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "qf",
		callback = function(event)
			keymap.set("<CR>", function()
				local win = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
				local hub_key = win.loclist == 1 and "loc" or "qf"
				hubs[hub_key].clear_pending()
				vim.cmd(win.loclist == 1 and "ll" or "cc")
				for _, w in ipairs(vim.fn.getwininfo()) do
					if w.quickfix == 1 then
						vim.cmd(w.loclist == 1 and "lclose" or "cclose")
						return
					end
				end
			end, { buffer = event.buf, desc = "Jump and close list" })
		end,
	})
end

return M
