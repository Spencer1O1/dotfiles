--- ]x/[x next/prev · ]X/[X last/first · hubs i o p · motion t g d
--- i/o/p: gather (lower) · trouble display (upper I/O/P) · ]x nav from code
local bind = require("spencerls.nav.bind")
local list = require("spencerls.nav.list")
local motions = require("spencerls.nav.motions")

bind.clear_defaults()

local hubs = {}
local M = {}

M.i = list.setup("i", false, "result", hubs)
M.o = list.setup("o", true, "symbol", hubs)
M.p = list.setup("p", "diagnostics", "diagnostic", hubs)

motions.setup()
list.setup_qf_autocmd(hubs)

return M
