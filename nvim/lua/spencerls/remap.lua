local keymap = require("spencerls.keymap")

-- Root leader primitives

keymap.leader("w", "<cmd>w<CR>", { desc = "Save file" })
keymap.leader("q", "<cmd>q<CR>", { desc = "Quit" })
keymap.leader("qa", "<cmd>qa<CR>", { desc = "Quit all" })
keymap.leader("Q", "<cmd>q!<CR>", { desc = "Force Quit" })

-- Clipboard edits

keymap.set("<C-v>", [["+p]], {
	mode = { "n", "v" },
	desc = "Paste from clipboard",
})
keymap.set("<C-v>", [[<C-r>+]], {
	mode = "i",
	desc = "Paste from clipboard",
})
keymap.set("<C-c>", [["+y]], {
	mode = { "n", "v" },
	desc = "Copy to clipboard",
})

-- Delete without copy

keymap.leader("d", [["_d]], {
	mode = { "n", "v" },
	desc = "Delete without copy",
})

-- Editing motion tweaks

keymap.set("J", ":m '>+1<CR>gv=gv", { mode = "v", desc = "Move code down" })
keymap.set("K", ":m '<-2<CR>gv=gv", { mode = "v", desc = "Move code up" })
keymap.set("Y", "yg$", { desc = "Yank to end of line" })
keymap.set("J", "mzJ`z", { desc = "Join line and keep cursor" })
keymap.set("<C-d>", "<C-d>zz", { desc = "Half-page down centered" })
keymap.set("<C-u>", "<C-u>zz", { desc = "Half-page up centered" })
keymap.set("n", "nzzzv", { desc = "Next search centered" })
keymap.set("N", "Nzzzv", { desc = "Previous search centered" })
keymap.set("Q", "<nop>", { desc = "Avoid worst place in the universe" })
-- keymap.set("<C-c>", "<Esc>", { mode = "i", desc = "Escape insert mode" })

-- misc

keymap.leader("r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace text" })
keymap.leader("X", "<cmd>!chmod +x %<CR>", { desc = "Make executable (linux)" })