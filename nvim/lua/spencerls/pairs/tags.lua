local util = require("spencerls.pairs.util")

local html_void = {
	area = true,
	base = true,
	br = true,
	col = true,
	embed = true,
	hr = true,
	img = true,
	input = true,
	link = true,
	meta = true,
	param = true,
	source = true,
	track = true,
	wbr = true,
}

local blacklist = { c = true, cpp = true }

local M = {}

function M.opening_at_end(text)
	return vim.fn.matchstr(text, [[<[A-Za-z]\%([^<>"']\|"[^"]*"\|'[^']*'\)*>\s*$]])
end

function M.tag_name(opening)
	return vim.fn.matchstr(opening, [[^<\zs[A-Za-z][A-Za-z0-9:_-]*]])
end

function M.inside_quote(fragment)
	local quote = ""
	local escaped = false
	for _, char in ipairs(vim.fn.split(fragment, [[\zs]])) do
		if escaped then
			escaped = false
		elseif char == "\\" then
			escaped = true
		elseif quote == "" and (char == '"' or char == "'") then
			quote = char
		elseif char == quote then
			quote = ""
		end
	end
	return quote ~= ""
end

function M.matching_widths()
	local before = vim.fn.strpart(vim.fn.getline("."), 0, vim.fn.col(".") - 1)
	local after = vim.fn.strpart(vim.fn.getline("."), vim.fn.col(".") - 1)
	local opening = M.opening_at_end(before)
	if opening == "" or opening:find("/>%s*$") then
		return nil
	end
	local tag = M.tag_name(opening)
	if tag == "" then
		return nil
	end
	local icase = vim.bo.filetype == "xml" and [[\C]] or [[\c]]
	local closing = vim.fn.matchstr(after, icase .. [[^\s*</]] .. vim.fn.escape(tag, [[\]]) .. [[\s*>]])
	if closing == "" then
		return nil
	end
	return vim.fn.strchars(opening), vim.fn.strchars(closing)
end

function M.is_pair()
	return util.char_before() == ">" and util.char_after() == "<" and M.matching_widths() ~= nil
end

function M.close()
	if blacklist[vim.bo.filetype] then
		return ">"
	end
	local line = vim.fn.getline(".")
	local split_at = vim.fn.col(".") - 1
	local before = vim.fn.strpart(line, 0, split_at)
	local after = vim.fn.strpart(line, split_at)
	local fragment = vim.fn.matchstr(before, "<[^<>]*$")
	if
		fragment == ""
		or fragment:find("^<%s*[!/?]")
		or fragment:find("/%s*$")
		or M.inside_quote(fragment)
	then
		return ">"
	end
	local tag = vim.fn.matchstr(fragment, [[^<\zs[A-Za-z][A-Za-z0-9:_-]*]])
	if tag == "" then
		return ">"
	end
	local existing = after:sub(1, 1) == ">"
	local insert = existing and "<Right>" or ">"
	local after_delim = existing and after:sub(2) or after
	if vim.bo.filetype ~= "xml" and html_void[tag:lower()] then
		return insert
	end
	if after_delim:lower():find("^%s*</" .. tag:lower() .. "[%s>]") then
		return insert
	end
	local closing = "</" .. tag .. ">"
	return insert .. closing .. string.rep("<Left>", vim.fn.strchars(closing))
end

return M
