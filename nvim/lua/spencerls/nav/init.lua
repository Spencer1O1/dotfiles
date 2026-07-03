--- ]x/[x next/prev · ]X/[X last/first · hubs i o z · motion t g d
local bind = require("spencerls.nav.bind")
local list = require("spencerls.nav.list")
local motions = require("spencerls.nav.motions")
local diagnostics = require("spencerls.nav.diagnostics")

bind.clear_defaults()

local hubs = {}
local M = {}

M.i = list.setup("i", false, "result", hubs)
M.o = list.setup("o", true, "symbol", hubs)

diagnostics.setup()
motions.setup()
list.setup_qf_autocmd(hubs)

return M
