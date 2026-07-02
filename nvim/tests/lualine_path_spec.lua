local lualine_path = require("spencerls.lualine_path")

local function assert_eq(expected, actual, label)
	if expected ~= actual then
		error(string.format("%s\n  expected: %q\n  actual:   %q", label, expected, actual))
	end
end

local tests = {}

function tests.oil_dotfiles_root()
	local path = lualine_path.display("oil:///C/Users/spencerls/dotfiles/")
	assert(path:match("dotfiles"), "dotfiles root: " .. path)
	if vim.fn.has("win32") == 1 and path:match("^C\\") and not path:match("^~") and not path:match("^C:") then
		error("missing drive colon: " .. path)
	end
end

function tests.oil_subdirectory()
	local path = lualine_path.display("oil:///C/Users/spencerls/dotfiles/pwsh/")
	assert(path:match("pwsh"), "pwsh subdir: " .. path)
	assert(path:match("dotfiles"), "should include parent: " .. path)
end

function tests.oil_drive_root()
	if vim.fn.has("win32") ~= 1 then
		return
	end
	local path = lualine_path.display("oil:///C/")
	assert(path:match("^C:") or path:match("^~"), "drive root: " .. path)
end

function tests.non_oil_empty()
	assert_eq("[No Name]", lualine_path.display(""), "empty bufname")
end

local passed, failed = 0, 0
for name, fn in pairs(tests) do
	local ok, err = pcall(fn)
	if ok then
		passed = passed + 1
		print("ok - " .. name)
	else
		failed = failed + 1
		print("FAIL - " .. name)
		print("  " .. tostring(err))
	end
end

print(string.format("\n%d passed, %d failed", passed, failed))
vim.cmd("cquit " .. (failed > 0 and 1 or 0))
