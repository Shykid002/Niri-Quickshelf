return {
  -- Shows available <leader> keybinds as you type
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      win = { border = "single" },
    },
  },
  -- Clean statusline that automatically inherits your rice StatusLine / Cover highlights
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "auto",
        component_separators = { left = "·", right = "·" },
        section_separators = { left = "", right = "" },
      },
    },
  },
}

