local function transparent(theme)
	for _, section in pairs(theme) do
		if section.c then
			section.c.bg = nil
		end
	end
	return theme
end

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"folke/tokyonight.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		lazy = false,
		opts = {
			options = {
				theme = transparent(require("lualine.themes.tokyonight")),
				globalstatus = true,
				component_separators = "",
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = { "dashboard", "alpha", "lazy" },
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = {
					{
						function()
							return require("spencerls.lualine_path").get()
						end,
					},
				},
				lualine_x = { "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
	},
}
