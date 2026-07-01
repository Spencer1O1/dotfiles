vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.clipboard = "unnamedplus"

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- undotree (and :diff) need GNU diff; Git for Windows ships it but not on PATH.
if vim.fn.has("win32") == 1 and vim.fn.executable("diff") == 0 then
	local git = vim.fn.exepath("git")
	if git ~= "" then
		local git_usrs_bin = vim.fn.fnamemodify(git, ":h:h") .. "/usr/bin"
		if vim.fn.isdirectory(git_usrs_bin) == 1 then
			vim.env.PATH = git_usrs_bin .. ";" .. (vim.env.PATH or "")
		end
	end
end
