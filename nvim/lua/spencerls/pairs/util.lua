local M = {}

function M.char_before()
	local pos = vim.fn.col(".") - 1
	if pos <= 0 then
		return ""
	end
	return vim.fn.strpart(vim.fn.getline("."), pos - 1, 1)
end

function M.char_after()
	return vim.fn.strpart(vim.fn.getline("."), vim.fn.col(".") - 1, 1)
end

function M.indent_text(cols)
	if vim.bo.expandtab then
		return string.rep(" ", cols)
	end
	local sw = vim.fn.shiftwidth()
	return string.rep("\t", math.floor(cols / sw)) .. string.rep(" ", cols % sw)
end

function M.structural_newline()
	local base = vim.fn.indent(".")
	local inner = base + vim.fn.shiftwidth()
	return "<CR><C-o>d0"
		.. M.indent_text(inner)
		.. "<CR><C-o>d0"
		.. M.indent_text(base)
		.. "<Up><End>"
end

return M
