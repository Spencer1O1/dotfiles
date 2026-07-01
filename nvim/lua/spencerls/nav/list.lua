local keymap = require("spencerls.keymap")
local bind = require("spencerls.nav.bind")
local util = require("spencerls.nav.util")
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

function M.setup(letter, loc, label, hubs)
	local k = make_kind(loc)
	local pending = false
	local H = {}

	function H.fill(what)
		if #what.items == 0 then
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
		vim.api.nvim_exec_autocmds("QuickFixCmdPre", {})
		vim.fn.setqflist(entries, " ")
		if title then
			vim.fn.setqflist({}, "a", { title = title })
		end
		vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
		pending = false
	end

	local function empty()
		return #k.get() == 0
	end

	bind.bind_nav(letter, label, function()
		if empty() then
			return
		end
		if pending then
			pending = false
			jump_list(k, k.idx())
			return
		end
		util.cmd_wrap(k.next, k.wn)
	end, function()
		if empty() then
			return
		end
		pending = false
		util.cmd_wrap(k.prev, k.wp)
	end, function()
		if empty() then
			return
		end
		pending = false
		jump_list(k, #k.get())
	end, function()
		if empty() then
			return
		end
		pending = false
		jump_list(k, 1)
	end)

	keymap.leader(letter:upper(), function()
		if k.loclist == 1 and empty() then
			return
		end
		for _, win in ipairs(vim.fn.getwininfo()) do
			if win.quickfix == 1 and win.loclist == k.loclist then
				vim.cmd(k.close)
				return
			end
		end
		vim.cmd(k.loclist == 1 and "lopen" or "copen")
	end, { desc = "Toggle " .. label .. " window" })

	hubs[loc and "loc" or "qf"] = H
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
