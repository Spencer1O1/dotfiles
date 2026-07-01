--- All keymaps go through this module. Do not call vim.keymap.set elsewhere.
---
--- Navigation: see nav.lua (3 types — qf hub, loclist hub, in-buffer motion).
---
---   set(lhs, rhs, opts?)       — any key chord
---   leader(suffix, rhs, opts?) — <leader> + suffix; opts.group → <leader>g… / <leader>l… / <leader>h
---
--- opts:
---   lazy   = true  return a lazy.nvim keys spec instead of binding now
---   buffer = bufnr buffer-local bind
---   group  = "git" | "language" | "harpoon"  (leader only; which-key prefix)
---   mode, desc, silent, …        passed to vim.keymap.set
local M = {}

M.leader_groups = {
	git = { key = "g", name = "git" },
	language = { key = "l", name = "language" },
	harpoon = { key = "h", name = "harpoon" },
}

local function caller()
	local info = debug.getinfo(4, "Sl")
	return info and (info.short_src .. ":" .. info.currentline) or "unknown"
end

local function parse_opts(options)
	local opts = vim.deepcopy(options or {})
	opts.lazy = nil
	opts.group = nil
	local mode = opts.mode or "n"
	opts.mode = nil
	if opts.silent == nil then
		opts.silent = true
	end
	return mode, opts
end

local function track(mode, lhs)
	local modes = type(mode) == "table" and table.concat(mode, ",") or mode
	local key = modes .. "\0" .. lhs
	local where = caller()
	if registry[key] and registry[key] ~= where then
		error(string.format("Duplicate %s (%s) — first at %s", lhs, modes, registry[key]))
	end
	registry[key] = where
end

local function bind(lhs, rhs, options)
	local mode, opts = parse_opts(options)
	if options and options.lazy then
		track(mode, lhs)
		return vim.tbl_extend("force", { lhs, rhs, mode = mode }, opts)
	end
	vim.keymap.set(mode, lhs, rhs, opts)
	if opts.buffer == nil then
		track(mode, lhs)
	end
end

local function leader_lhs(suffix, group)
	if group then
		local config = M.leader_groups[group]
		if not config then
			error("Unknown group: " .. group)
		end
		return "<leader>" .. config.key .. suffix
	end
	return "<leader>" .. suffix
end

function M.set(lhs, rhs, options)
	return bind(lhs, rhs, options)
end

function M.leader(suffix, rhs, options)
	options = vim.deepcopy(options or {})
	local group = options.group
	return bind(leader_lhs(suffix, group), rhs, options)
end

function M.which_key_spec()
	local spec = {}
	for _, group in pairs(M.leader_groups) do
		spec[#spec + 1] = { "<leader>" .. group.key, group = group.name }
	end
	return spec
end

return M
