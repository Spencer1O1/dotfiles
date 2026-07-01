local function has_config(filename, names)
  return vim.fs.find(names, {
    path = filename,
    upward = true,
  })[1] ~= nil
end

local function buffer_has_config(bufnr, names)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  return has_config(filename, names)
end

local function is_c_family(bufnr)
  local filetype = vim.bo[bufnr].filetype
  return filetype == "c" or filetype == "cpp"
end

local function get_format_opts(bufnr)
  if is_c_family(bufnr) and not buffer_has_config(bufnr, { ".clang-format", "_clang-format" }) then
    return nil
  end

  return {
    timeout_ms = 3000,
    lsp_format = is_c_family(bufnr) and "never" or "fallback",
  }
end

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>lf",
        function()
          local opts = get_format_opts(0)

          if opts == nil then
            vim.notify("No formatter config found for this file", vim.log.levels.WARN)
            return
          end

          opts.async = true
          require("conform").format(opts)
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters = {
        biome = {
          condition = function(ctx)
            return has_config(ctx.filename, { "biome.json", "biome.jsonc" })
          end,
        },

        prettier = {
          condition = function(ctx)
            return not has_config(ctx.filename, { "biome.json", "biome.jsonc" })
          end,
        },

        clang_format = {
          condition = function(ctx)
            return has_config(ctx.filename, { ".clang-format", "_clang-format" })
          end,
        },
      },

      formatters_by_ft = {
        lua = { "stylua" },

        javascript = { "biome", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "prettier", stop_after_first = true },
        typescript = { "biome", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "prettier", stop_after_first = true },

        css = { "biome", "prettier", stop_after_first = true },
        html = { "prettier" },
        json = { "biome", "prettier", stop_after_first = true },
        jsonc = { "biome", "prettier", stop_after_first = true },
        yaml = { "prettier" },
        markdown = { "prettier" },
        markdown_inline = { "prettier" },

        python = { "isort", "black" },

        sh = { "shfmt" },
        bash = { "shfmt" },

        c = { "clang_format" },
        cpp = { "clang_format" },

        go = { "gofmt" },
        rust = { "rustfmt" },

        php = { "php_cs_fixer" },
      },

      format_on_save = function(bufnr)
        return get_format_opts(bufnr)
      end,
    },
  },
}