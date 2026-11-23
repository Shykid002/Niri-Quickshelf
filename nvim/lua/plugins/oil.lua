return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false, -- Load immediately so `nvim .` opens Oil cleanly
    keys = {
      { "-",          "<cmd>Oil --float<cr>", desc = "Open parent directory (Oil float)" },
      { "<leader>e",  "<cmd>Oil --float<cr>", desc = "File explorer (Oil float)" },
      { "<leader>E",  "<cmd>Oil<cr>",         desc = "File explorer (full buffer)" },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      prompt_save_on_select_new_entry = true,
      columns = {
        "icon",
        "size",
      },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          return name == ".." or name == ".git"
        end,
      },
      float = {
        padding = 3,
        max_width = 76,
        max_height = 28,
        border = "single", -- Sharp editorial corners matching your rice
        win_options = {
          winblend = 0,
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
        },
        override = function(conf)
          conf.title = " Folio Explorer "
          conf.title_pos = "center"
          return conf
        end,
      },
      preview_win = {
        update_on_cursor_moved = true,
        preview_method = "fast_scratch",
        win_options = {
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
      },
      keymaps = {
        ["q"]     = "actions.close",
        ["<Esc>"] = "actions.close",
        ["<CR>"]  = "actions.select",
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
        ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-p>"] = "actions.preview",
        ["-"]     = "actions.parent",
        ["_"]     = "actions.open_cwd",
        ["g."]    = "actions.toggle_hidden",
      },
    },
  },
}

