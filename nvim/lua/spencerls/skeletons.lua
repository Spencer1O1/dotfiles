-- Empty source files get a document wrapper so you do not retype the boilerplate.

local skeletons = {
	tex = {
		lines = {
			"\\documentclass[11pt]{article}",
			"\\usepackage{amsmath,amssymb}",
			"\\begin{document}",
			"",
			"\\end{document}",
		},
		cursor = { 4, 0 },
	},
	html = {
		lines = {
			"<!DOCTYPE html>",
			'<html lang="en">',
			"<head>",
			'  <meta charset="utf-8">',
			"  <title></title>",
			"</head>",
			"<body>",
			"  ",
			"</body>",
			"</html>",
		},
		cursor = { 8, 2 },
	},
}

skeletons.htm = skeletons.html

local function seed(spec)
	if vim.fn.line("$") ~= 1 or vim.fn.getline(1) ~= "" then
		return
	end
	vim.api.nvim_buf_set_lines(0, 0, -1, false, spec.lines)
	vim.api.nvim_win_set_cursor(0, spec.cursor)
end

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { "*.tex", "*.html", "*.htm" },
	callback = function(event)
		local ext = vim.fn.fnamemodify(event.file, ":e"):lower()
		local spec = skeletons[ext]
		if spec then
			seed(spec)
		end
	end,
})
