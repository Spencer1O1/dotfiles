local M = {}

---Replace oil's wmic-based drive listing (wmic is gone on modern Windows).
function M.patch_drive_listing()
	local files = require("oil.adapters.files")
	local cache = require("oil.cache")
	local util = require("oil.util")

	local orig_list = files.list
	files.list = function(url, column_defs, cb)
		local _, path = util.parse_url(url)
		if path ~= "/" then
			return orig_list(url, column_defs, cb)
		end

		local internal_entries = {}
		for code = string.byte("A"), string.byte("Z") do
			local letter = string.char(code)
			if vim.fn.isdirectory(letter .. ":/") == 1 then
				-- Entry name must be "C" not "C:" — oil builds /C/ from / + C + /
				table.insert(internal_entries, cache.create_entry(url, letter, "directory"))
			end
		end
		cb(nil, internal_entries)
	end
end

return M
