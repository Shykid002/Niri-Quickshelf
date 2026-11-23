return {
  -- ── Autopairs: auto-close (), [], {}, "", '' ─────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true, -- Use treesitter to avoid pairing inside strings/comments
      fast_wrap = {
        map = "<M-e>", -- Alt+e wraps the next word in brackets/quotes
      },
    },
  },

  -- ── Autocomplete: blink.cmp styled for Paper & Ink ────────
  {
    "saghen/blink.cmp",
    version = "1.*", -- Downloads prebuilt Rust fuzzy-matcher binary (no cargo needed)
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"]      = { "accept", "fallback" },
        ["<Tab>"]     = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"]   = { "select_prev", "snippet_backward", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"]     = { "hide", "fallback" },
        ["<C-u>"]     = { "scroll_documentation_up", "fallback" },
        ["<C-d>"]     = { "scroll_documentation_down", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        accept = {
          -- Automatically add () after completing functions/methods
          auto_brackets = { enabled = true },
        },
        menu = {
          border = "single", -- Sharp editorial frame matching your rice
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind", gap = 1 },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "single",
          },
        },
        ghost_text = {
          enabled = true, -- Subtle muted preview of top match inline
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      signature = {
        enabled = true,
        window = { border = "single" },
      },
    },
  },
}

