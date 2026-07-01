local keymap = require("spencerls.keymap")

return {
    {
      "stevearc/oil.nvim",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      keys = {
        keymap.lazy_leader("e", function()
            require("oil").open()
        end, {
            desc = "Explorer",
        }),
      },
      opts = {
        default_file_explorer = true,
  
        columns = {
          "icon",
        },
  
        view_options = {
          show_hidden = true,
        },
  
        skip_confirm_for_simple_edits = true,
  
        keymaps = {
          ["<CR>"] = "actions.select",
          ["<C-v>"] = "actions.select_vsplit",
          ["<C-s>"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
  
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
  
          ["g."] = "actions.toggle_hidden",
          ["q"] = "actions.close",
        },
      },
    },
  }