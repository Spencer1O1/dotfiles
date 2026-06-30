return {
  {
    "folke/tokyonight.nvim",
    -- "rose-pine/neovim",
    -- name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      })

      vim.cmd.colorscheme("tokyonight")

      -- require("rose-pine").setup({
      --   disable_background = true,
      --   disable_float_background = true,
      -- })

      -- vim.cmd.colorscheme("rose-pine")

      local transparent_groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "FloatBorder",
        "SignColumn",
        "LineNr",
        "CursorLineNr",
        "EndOfBuffer",
        "StatusLine",
        "StatusLineNC",
        "WinSeparator",
      }

      for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, { bg = "none" })
      end
    end,
  },
}
