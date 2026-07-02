local M = {}

---Same path display oil uses for its floating window title.
---@param bufname string
---@return string
function M.display(bufname)
	if bufname:match("^oil://") then
		local util = require("oil.util")
		local _, path = util.parse_url(bufname)
		if not path then
			return bufname
		end
		if vim.fn.has("win32") == 1 then
			path = require("oil.fs").posix_to_os_path(path)
		end
		return vim.fn.fnamemodify(path, ":~")
	end

	if bufname == "" then
		return "[No Name]"
	end

	local path = vim.fn.expand("%:~:.")
	if path == "" or path == "." then
		path = vim.fn.expand("%:~")
	end
	return path ~= "" and path or "[No Name]"
end

function M.get()
	local path = M.display(vim.api.nvim_buf_get_name(0))

	local ok, utils = pcall(require, "lualine.utils.utils")
	if ok then
		path = utils.stl_escape(path)
	end

	local symbols = {}
	if vim.bo.modified then
		table.insert(symbols, "[+]")
	end
	if vim.bo.modifiable == false or vim.bo.readonly then
		table.insert(symbols, "[-]")
	end

	if #symbols > 0 then
		path = path .. " " .. table.concat(symbols, "")
	end

	return path
end

return M
