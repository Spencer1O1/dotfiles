--- Session workspace for cursor-agent (and anything else that needs a project root).
local M = {}

M._override = nil

--- Nearest .git root from the current file's directory, else that directory.
--- Handles nested subprojects (each with their own .git) without using Neovim cwd.
function M.detect()
	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname == "" or vim.bo.buftype ~= "" then
		return vim.fn.getcwd()
	end

	local dir = vim.fn.fnamemodify(bufname, ":h")
	if dir == "" then
		return vim.fn.getcwd()
	end

	local git_root = vim.fs.root(dir, ".git")
	if git_root then
		return git_root
	end

	return dir
end

function M.get()
	if M._override then
		return M._override
	end
	return M.detect()
end

function M.tmp_dir()
	local dir = vim.fs.joinpath(M.get(), "tmp")
	vim.fn.mkdir(dir, "p")
	return vim.fs.normalize(dir)
end

--- Keep 99 TEMP_FILE paths under agent workspace (cursor-agent writes relative to --workspace).
function M.sync_99_tmp()
	local dir = M.tmp_dir()
	local ok, state = pcall(require("99").__get_state)
	if ok and state then
		state.__tmp_dir = dir
	end
	return dir
end

--- Session override set via :AgentWorkspace or 9h.
function M.set(path)
	M._override = vim.fn.fnamemodify(path, ":p")
	M.sync_99_tmp()
	vim.notify("agent workspace: " .. M._override, vim.log.levels.INFO)
end

function M.set_here()
	M.set(M.detect())
end

function M.clear()
	M._override = nil
	M.sync_99_tmp()
	vim.notify("agent workspace: auto → " .. M.detect(), vim.log.levels.INFO)
end

function M.register_commands()
	if M._commands_registered then
		return
	end
	M._commands_registered = true

	vim.api.nvim_create_user_command("AgentWorkspace", function(opts)
		local arg = opts.args
		if arg == "" or arg == "show" then
			vim.notify("agent workspace: " .. M.get(), vim.log.levels.INFO)
		elseif arg == "auto" then
			M.clear()
		elseif arg == "here" then
			M.set_here()
		else
			M.set(arg)
		end
	end, {
		nargs = "?",
		complete = "dir",
		desc = "cursor-agent workspace (:AgentWorkspace [show|auto|here|path])",
	})
end

return M
