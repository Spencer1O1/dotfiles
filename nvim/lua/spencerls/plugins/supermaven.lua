return {
	{
		"supermaven-inc/supermaven-nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("supermaven-nvim.completion_preview").suggestion_group = "SupermavenSuggestion"

			require("supermaven-nvim").setup({
				disable_keymaps = true,
				log_level = "off",
				color = {
					suggestion_color = "#557ac9",
				},
			})
		end,
	},
}
