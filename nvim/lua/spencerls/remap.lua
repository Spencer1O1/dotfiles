local keymap = require("spencerls.keymap")

-- Primitive leader mappings

keymap.leader("w", "<cmd>w<CR>", { desc = "Save file" })
keymap.leader("q", "<cmd>q<CR>", { desc = "Quit" })

keymap.leader("p", [["_dP]], {
	mode = "x",
	desc = "Paste without replacing register",
})

keymap.leader("y", [["+y]], {
	mode = { "n", "v" },
	desc = "Copy to system clipboard",
})
keymap.leader("d", [["_d]], {
	mode = { "n", "v" },
	desc = "Delete without replacing register",
})

keymap.leader("r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace" })
keymap.leader("X", "<cmd>!chmod +x %<CR>", { desc = "Make executable" })

-- Primitive mappings

keymap.map("J", ":m '>+1<CR>gv=gv", {
	mode = "v",
	desc = "Move selection down",
})
keymap.map("K", ":m '<-2<CR>gv=gv", {
	mode = "v",
	desc = "Move selection up",
})

keymap.map("Y", "yg$", { desc = "Yank to end of line" })
keymap.map("J", "mzJ`z", { desc = "Join line and keep cursor" })

keymap.map("<C-d>", "<C-d>zz", { desc = "Half-page down centered" })
keymap.map("<C-u>", "<C-u>zz", { desc = "Half-page up centered" })

keymap.map("n", "nzzzv", { desc = "Next search centered" })
keymap.map("N", "Nzzzv", { desc = "Previous search centered" })

keymap.map("<C-c>", "<Esc>", { mode = "i", desc = "Escape insert mode" })
keymap.map("Q", "<nop>", { desc = "Avoid worst place in the universe" })

-- Quickfix and location list mappings

keymap.map("<C-j>", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
keymap.map("<C-k>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })
keymap.map("<M-j>", "<cmd>lnext<CR>zz", { desc = "Next location item" })
keymap.map("<M-k>", "<cmd>lprev<CR>zz", { desc = "Previous location item" })

local function toggle_quickfix()
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 and win.loclist == 0 then
			vim.cmd("cclose")
			return
		end
	end

	vim.cmd("copen")
end

local function has_location_items()
	return #vim.fn.getloclist(0) > 0
end

local function toggle_location()
	if not has_location_items() then
		return
	end

	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 and win.loclist == 1 then
			vim.cmd("lclose")
			return
		end
	end

	vim.cmd("lopen")
end

keymap.leader("n", toggle_quickfix, {
	desc = "Toggle quickfix list",
})

keymap.leader("m", toggle_location, {
	desc = "Toggle location list",
})

