local util = require("spencerls.pairs.util")

local M = {}

function M.open(open, close)
	return open .. close .. "<Left>"
end

function M.close(close)
	if util.char_after() == close then
		return "<Right>"
	end
	return close
end

function M.quote(quote)
	if util.char_after() == quote then
		return "<Right>"
	end
	if util.char_before() == "\\" then
		return quote
	end
	if quote == "'" and util.char_before():match("%w") then
		return quote
	end
	return quote .. quote .. "<Left>"
end

function M.is_pair()
	local pair = util.char_before() .. util.char_after()
	return pair == "()" or pair == "[]" or pair == "{}"
end

return M
