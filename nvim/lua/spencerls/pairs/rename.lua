-- Rename the matching HTML/JSX tag while you edit one side.

local open_types = {
	start_tag = true,
	STag = true,
	jsx_opening_element = true,
}

local close_types = {
	end_tag = true,
	ETag = true,
	jsx_closing_element = true,
}

local name_types = {
	tag_name = true,
	Name = true,
	identifier = true,
}

local busy = false

local function node_text(node)
	return vim.treesitter.get_node_text(node, 0)
end

local function named_child(node, want)
	for child in node:iter_children() do
		if child:named() and want[child:type()] then
			return child
		end
	end
end

local function tag_side(node)
	while node do
		local t = node:type()
		if open_types[t] then
			return "open", node
		end
		if close_types[t] then
			return "close", node
		end
		node = node:parent()
	end
end

local function name_node(tag)
	return named_child(tag, name_types)
end

local function other_tag(tag, side)
	local parent = tag:parent()
	if not parent then
		return
	end
	local want = side == "open" and close_types or open_types
	for child in parent:iter_children() do
		if child:named() and want[child:type()] then
			return child
		end
	end
end

local function cursor_in_name(name)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1
	local sr, sc, er, ec = name:range()
	if row < sr or row > er then
		return false
	end
	if row == sr and col < sc then
		return false
	end
	if row == er and col > ec then
		return false
	end
	return true
end

local function rename()
	if busy or vim.fn.mode() ~= "i" then
		return
	end
	local ok, node = pcall(vim.treesitter.get_node, { ignore_injections = false })
	if not ok or not node then
		return
	end
	local side, tag = tag_side(node)
	if not side then
		return
	end
	local here = name_node(tag)
	if not here or not cursor_in_name(here) then
		return
	end
	local there_tag = other_tag(tag, side)
	if not there_tag then
		return
	end
	local there = name_node(there_tag)
	if not there then
		return
	end
	local src = node_text(here)
	local dst = node_text(there)
	if src == "" or src == dst then
		return
	end
	local sr, sc, er, ec = there:range()
	busy = true
	pcall(vim.api.nvim_buf_set_text, 0, sr, sc, er, ec, vim.split(src, "\n", { plain = true }))
	busy = false
end

vim.api.nvim_create_autocmd("TextChangedI", {
	callback = rename,
})
