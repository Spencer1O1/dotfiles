local keymap = require("spencerls.keymap")

local function map_99(lhs, rhs, opts)
	return keymap.set(lhs, rhs, vim.tbl_extend("force", { lazy = true }, opts or {}))
end

return {
	{
		"Spencer1O1/99",
		branch = "master",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"nvim-lua/plenary.nvim",
			"folke/trouble.nvim",
			"nvim-telescope/telescope.nvim",
		},
		keys = {
			map_99("9s", function()
				require("99").search()
			end, { desc = "99 search" }),
			map_99("9v", function()
				require("99").vibe()
			end, { desc = "99 vibe (agent implement)" }),
			map_99("9v", function()
				require("99").visual()
			end, { mode = "v", desc = "99 visual" }),
			map_99("9o", function()
				require("99").open()
			end, { desc = "99 open last result" }),
			map_99("9x", function()
				require("99").stop_all_requests()
			end, { desc = "99 stop requests" }),
			map_99("9i", function()
				require("99").info()
			end, { desc = "99 info" }),
			map_99("9l", function()
				require("99").view_logs()
			end, { desc = "99 view logs" }),
			map_99("9w", function()
				require("99").Extensions.Worker.set_work()
			end, { desc = "99 set work item" }),
			map_99("9W", function()
				require("99").Extensions.Worker.search()
			end, { desc = "99 search remaining work" }),
			map_99("9m", function()
				require("99.extensions.telescope").select_model()
			end, { desc = "99 select model" }),
			map_99("9p", function()
				require("99.extensions.telescope").select_provider()
			end, { desc = "99 select provider" }),
		},
		config = function()
			local _99 = require("99")

			_99.setup({
				provider = _99.Providers.CursorAgentProvider,
				model = "composer-2.5-fast",
				display_errors = true,
				tmp_dir = "./tmp",
				md_files = {
					"AGENTS.md",
					"AGENT.md",
				},
				completion = {
					custom_rules = {
						vim.fn.expand("~/.cursor/skills-cursor/"),
					},
					source = "cmp",
				},
			})

			_99.open_qfix_for_request = function(request)
				local items = request:qfix_data()
				if #items == 0 then
					local raw = request.data and request.data.response or ""
					if raw:match("%S") then
						vim.notify(
							"99: agent responded but no locations matched the qfix format — try 9l for logs",
							vim.log.levels.WARN
						)
					else
						vim.notify("99: no results to show", vim.log.levels.INFO)
					end
					return
				end

				vim.fn.setqflist({}, "r", { title = "99 Results", items = items })
				require("spencerls.nav.trouble").show("qflist")
			end

			vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
				group = vim.api.nvim_create_augroup("spencerls_99_prompt", { clear = true }),
				callback = function(event)
					local buf = event.buf
					if vim.bo[buf].buftype ~= "acwrite" then
						return
					end
					if not vim.api.nvim_buf_get_name(buf):match("99%-prompt") then
						return
					end
					if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
						vim.cmd("startinsert")
					end
				end,
			})

			if vim.fn.executable("cursor-agent") == 1 then
				vim.system({ "cursor-agent", "status" }, { text = true }, function(obj)
					vim.schedule(function()
						local out = (obj.stdout or "") .. (obj.stderr or "")
						if out:match("Not logged in") or out:match("Authentication required") then
							vim.notify(
								"99: cursor-agent is not logged in — run `agent login` in a terminal, then retry",
								vim.log.levels.WARN
							)
						end
					end)
				end)
			end
		end,
	},
}
