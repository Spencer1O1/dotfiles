--- Nearest .git root from the current buffer, else the buffer's directory.
local M = {}

function M.detect()
	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname == "" or vim.bo.buftype ~= "" then
		return vim.fn.getcwd()
	end

	local dir = vim.fn.fnamemodify(bufname, ":h")
	if dir == "" then
		return vim.fn.getcwd()
	end

	return vim.fs.root(dir, ".git") or dir
end

--- Set window-local cwd to project root (99 tmp_dir and --workspace use getcwd()).
function M.lcd_here()
	local root = vim.fs.normalize(M.detect())
	vim.cmd.lcd(vim.fn.fnameescape(root))
	vim.notify("pwd → " .. root, vim.log.levels.INFO)
end

function M.setup()
	local keymap = require("spencerls.keymap")
	keymap.leader("cd", function()
		M.lcd_here()
	end, { desc = "pwd → project root (lcd)" })
end

return M
