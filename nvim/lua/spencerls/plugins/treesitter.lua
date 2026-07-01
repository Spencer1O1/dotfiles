local parsers = {
  "bash",
  "c",
  "cpp",
  "css",
  "go",
  "gomod",
  "html",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "php",
  "python",
  "query",
  "rust",
  "templ",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      require("nvim-treesitter").install(parsers)

      local function has_ts_parser(lang)
        return vim.list_contains(require("nvim-treesitter").get_installed("parsers"), lang)
      end

      local function start_ts(event)
        local buf = event.buf
        local lang = vim.bo[buf].filetype
        if lang == "" or not has_ts_parser(lang) then
          if lang ~= "" and not has_ts_parser(lang) then
            vim.notify(
              string.format('Treesitter parser for "%s" missing — run :TSInstall %s', lang, lang),
              vim.log.levels.WARN
            )
          end
          return
        end
        pcall(vim.treesitter.start, buf, lang)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = parsers,
        callback = start_ts,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = parsers,
        callback = function(event)
          local lang = vim.bo[event.buf].filetype
          if has_ts_parser(lang) then
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexp()"
          end
        end,
      })
    end,
  },
}
