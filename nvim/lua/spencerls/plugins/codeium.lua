return {
<<<<<<< HEAD
	{
		"Exafunction/windsurf.nvim",
		cmd = "Codeium",
		event = "InsertEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			-- Skip browser UI — print URL, read token from clipboard.
			package.preload["codeium.views.auth-menu"] = function()
				return function(_, on_submit)
					vim.print("Codeium auth URL (open in your browser):")
					vim.print("https://windsurf.com/vim-show-auth-token?redirect_uri=vim-show-auth-token")
					vim.print("")
					vim.fn.input("Copy token to clipboard, then press Enter ")

					local token = vim.fn.getreg("+")
					if token == "" then
						token = vim.fn.getreg("*")
					end
					on_submit(token)
				end
			end
			package.loaded["codeium.views.auth-menu"] = nil

			require("codeium").setup({
				enable_cmp_source = false,
				enable_chat = false,
				quiet = true,
				virtual_text = {
					enabled = true,
					manual = false,
					idle_delay = 150,
					map_keys = false,
				},
			})
=======
  {
    "Exafunction/windsurf.nvim",
    cmd = "Codeium",
    event = "InsertEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- Skip browser UI — print URL, read token from clipboard.
      package.preload["codeium.views.auth-menu"] = function()
        return function(url, on_submit)
          vim.print("Codeium auth URL (open in your browser):")
          vim.print(url)
          vim.print("")
          vim.fn.input("Copy token to clipboard, then press Enter ")
>>>>>>> b4474d9 (remove test)

          local token = vim.fn.getreg("+")
          if token == "" then
            token = vim.fn.getreg("*")
          end
          on_submit(token)
        end
      end
      package.loaded["codeium.views.auth-menu"] = nil
      require("codeium").setup({
        enable_cmp_source = false,
        enable_chat = false,
        quiet = true,
        virtual_text = {
          enabled = true,
          manual = false,
          idle_delay = 150,
          map_keys = false,
        },
      })

      -- Neovim buffers are always LF; Codeium defaults to CRLF on Windows (fileformat=dos)
      -- and inserts literal ^M when accepting multi-line completions.
      local util = require("codeium.util")
      util.get_newline = function(_)
        return "\n"
      end

      local virtual_text = require("codeium.virtual_text")
      local get_completion_text = virtual_text.get_completion_text
      virtual_text.get_completion_text = function()
        return get_completion_text():gsub("\r", "")
      end
    end,
  },
}
