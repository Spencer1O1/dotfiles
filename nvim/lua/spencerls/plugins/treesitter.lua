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

      local function enable_ts_folds(buf)
        if vim.bo[buf].buftype ~= "" then
          return
        end
        if not vim.treesitter.get_parser(buf, nil, { error = false }) then
          return
        end
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      end

      local function setup_ts_buffer(event)
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
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = parsers,
        callback = setup_ts_buffer,
      })

      vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function(event)
          enable_ts_folds(event.buf)
        end,
      })
    end,
  },
}
