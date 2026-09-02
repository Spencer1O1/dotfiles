return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
			"supermaven-inc/supermaven-nvim",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local suggestion = require("supermaven-nvim.completion_preview")

			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_lua").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/lua/spencerls/snippets" },
			})

			local completion_sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "path" },
			}, {
				{ name = "buffer", keyword_length = 1 },
			})

			local function accept_supermaven(partial)
				local inlay = suggestion:get_inlay_instance()
				if not inlay or not inlay.completion_text or inlay.completion_text == "" then
					return false
				end
				inlay.is_active = true
				if partial then
					suggestion.on_accept_suggestion_word()
				else
					suggestion.on_accept_suggestion()
				end
				return true
			end

			local function open_menu()
				cmp.complete({
					reason = cmp.ContextReason.Manual,
					config = { sources = completion_sources },
				})
			end

			local function expand_pair(fallback)
				local keys = require("spencerls.pairs").enter()
				if keys == "<CR>" then
					fallback()
					return
				end
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes(keys, true, false, true),
					"n",
					false
				)
			end

			cmp.setup({
				preselect = cmp.PreselectMode.Item,
				completion = {
					autocomplete = false,
					completeopt = "menu,menuone,noinsert",
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = {
					["<C-n>"] = cmp.mapping(function()
						if cmp.visible() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						else
							open_menu()
						end
					end, { "i", "s" }),
					["<C-p>"] = cmp.mapping(function()
						if cmp.visible() then
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
						else
							open_menu()
						end
					end, { "i", "s" }),
					["<Esc>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.abort()
							return
						end
						fallback()
					end, { "i", "s" }),
					["<C-f>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.confirm({ select = true })
							return
						end
						if not accept_supermaven(false) then
							fallback()
						end
					end, { "i", "s" }),
					["<C-S-f>"] = cmp.mapping(function(fallback)
						if not accept_supermaven(true) then
							fallback()
						end
					end, { "i", "s" }),
					["<CR>"] = cmp.mapping(expand_pair, { "i", "s" }),
				},
				sources = completion_sources,
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},
}
