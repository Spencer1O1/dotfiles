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

        -- Menu open: cycle. In snippet: advance. Otherwise: ghost text, then normal tab.
        ["<Tab>"] = {
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.select_next()
            end

            return cmp.accept()
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.select_prev()
            end
          end,
          "snippet_backward",
          "fallback",
        },

        -- When the tab menu is open, accept the selected item. Otherwise behave like normal enter.
        ["<CR>"] = {
          function(cmp)
            if cmp.is_menu_visible() then
              return cmp.accept()
            end
          end,
          "fallback_to_mappings",
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
        default = { "lsp", "path", "snippets" },
      },

      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
    },
    opts_extend = { "sources.default" },
  },
}
