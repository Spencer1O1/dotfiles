local keymap = require("spencerls.keymap")

return {
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        preset = "modern",
        spec = keymap.which_key_spec(),
      },
    },
  }