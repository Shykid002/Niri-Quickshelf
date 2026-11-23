

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({})

      local parsers = { "lua", "qmljs", "bash", "fish", "kdl", "json", "toml", "markdown" }
      ts.install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lua", "qml", "sh", "bash", "fish", "kdl", "json", "toml", "markdown" },
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}

