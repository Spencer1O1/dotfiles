return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "none",
        -- Keep this aligned with PowerShell: Ctrl+Space opens completion.

        -- Manual menu, like PowerShell Ctrl+J.
        ["<C-j>"] = {
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.hide()
            end

            return cmp.show()
          end,
        },

        -- When the tab menu is open, Tab cycles. Otherwise, accepts ghost text or behaves as normal tab.
        ["<Tab>"] = { 
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.select_next()
            end

            if cmp.is_ghost_text_visible() then
              return cmp.accept()
            end
          end,
          "fallback",
        },
        ["<S-Tab>"] = { 
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.select_prev()
            end
          end,
          "fallback",
        },

        -- When the tab menu is open, select the item. Otherwise behave like normal enter.
        ["<CR>"] = {
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.accept()
            end
          end,
          "fallback",
        },

        -- Reserve Ctrl+F for AI ghost-text acceptance later.
      },
      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        menu = {
          auto_show = false,
        },

        ghost_text = {
          enabled = true,
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 300,
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
    },
    opts_extend = { "sources.default" },
  },
}
