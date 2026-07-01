local M = {}

function M.center()
	vim.cmd.normal({ "zz", bang = true })
end

function M.top()
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

function M.bottom()
	vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(0), 0 })
end

function M.cmd_wrap(next_cmd, wrap_cmd)
	if not pcall(vim.cmd, next_cmd) then
		vim.cmd(wrap_cmd)
	end
	M.center()
end

function M.wrap(jump, reset)
	local before = vim.api.nvim_win_get_cursor(0)
	jump()
	local after = vim.api.nvim_win_get_cursor(0)
	if after[1] == before[1] and after[2] == before[2] then
		reset()
		jump()
	end
	M.center()
end

return M
