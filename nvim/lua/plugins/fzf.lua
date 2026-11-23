return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>",      desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>",  desc = "Search text in project" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>",    desc = "Open buffers" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>",   desc = "Recent files" },
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>",  desc = "Help tags" },
      { "<leader>fc", "<cmd>FzfLua commands<cr>",   desc = "Commands" },
      { "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document diagnostics" },
      { "<leader><leader>", "<cmd>FzfLua files<cr>", desc = "Quick find files" },
    },
    opts = {
      "border-fused",
      winopts = {
        height = 0.82,
        width  = 0.84,
        row    = 0.50,
        col    = 0.50,
        border = "single", -- Crisp editorial corners matching your rice
        preview = {
          border = "single",
          layout = "flex",
          flip_columns = 120,
        },
      },
      -- Map fzf colors directly to your live Paper & Ink highlight groups
      hls = {
        normal         = "NormalFloat",
        border         = "FloatBorder",
        title          = "FloatTitle",
        preview_normal = "Normal",
        preview_border = "FloatBorder",
        preview_title  = "FloatTitle",
        cursor         = "Cursor",
        cursorline     = "CursorLine",
        search         = "IncSearch",
      },
      fzf_colors = {
        ["fg"]      = { "fg", "NormalFloat" },
        ["bg"]      = { "bg", "NormalFloat" },
        ["hl"]      = { "fg", "Keyword" },      -- Uses your active Cover colour!
        ["fg+"]     = { "fg", "StatusLine" },   -- Uses Cover foreground!
        ["bg+"]     = { "bg", "StatusLine" },   -- Uses Cover background!
        ["hl+"]     = { "fg", "StatusLine" },
        ["info"]    = { "fg", "Comment" },
        ["border"]  = { "fg", "FloatBorder" },
        ["prompt"]  = { "fg", "Keyword" },
        ["pointer"] = { "fg", "StatusLine" },
        ["marker"]  = { "fg", "Keyword" },
        ["spinner"] = { "fg", "Keyword" },
        ["header"]  = { "fg", "Comment" },
      },
      files = {
        prompt = "Files ❯ ",
      },
      grep = {
        prompt = "Grep ❯ ",
      },
    },
  },
}

