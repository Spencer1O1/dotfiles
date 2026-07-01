local keymap = require("spencerls.keymap")

-- Root leader primitives

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

-- Editing motion tweaks

keymap.set("J", ":m '>+1<CR>gv=gv", { mode = "v", desc = "Move selection down" })
keymap.set("K", ":m '<-2<CR>gv=gv", { mode = "v", desc = "Move selection up" })
keymap.set("Y", "yg$", { desc = "Yank to end of line" })
keymap.set("J", "mzJ`z", { desc = "Join line and keep cursor" })
keymap.set("<C-d>", "<C-d>zz", { desc = "Half-page down centered" })
keymap.set("<C-u>", "<C-u>zz", { desc = "Half-page up centered" })
keymap.set("n", "nzzzv", { desc = "Next search centered" })
keymap.set("N", "Nzzzv", { desc = "Previous search centered" })
keymap.set("<C-c>", "<Esc>", { mode = "i", desc = "Escape insert mode" })
keymap.set("Q", "<nop>", { desc = "Avoid worst place in the universe" })
