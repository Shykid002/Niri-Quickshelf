return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", opts = { ui = { border = "single" } } },
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          ensure_installed = { "lua_ls" },
          automatic_enable = true,
        },
      },
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Configure Lua LS (recognizes `vim` global without warnings)
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- Configure Bash LS (uses system `bash-language-server` package)
      vim.lsp.config("bashls", {
        capabilities = capabilities,
      })
      if vim.fn.executable("bash-language-server") == 1 then
        vim.lsp.enable("bashls")
      end

      -- Configure Python LSP (`pyright` for types/completion + `ruff` for linting)
      if vim.fn.executable("pyright-langserver") == 1 then
        vim.lsp.config("pyright", {
          capabilities = capabilities,
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        })
        vim.lsp.enable("pyright")
      end

      if vim.fn.executable("ruff") == 1 then
        vim.lsp.config("ruff", {
          capabilities = capabilities,
        })
        vim.lsp.enable("ruff")
      end

      -- Enable system `qmlls` (Qt6 QML Language Server) if installed on Arch
      if vim.fn.executable("qmlls6") == 1 or vim.fn.executable("qmlls") == 1 then
        local qml_bin = vim.fn.executable("qmlls6") == 1 and "qmlls6" or "qmlls"
        vim.lsp.config("qmlls", {
          cmd = { qml_bin },
          capabilities = capabilities,
        })
        vim.lsp.enable("qmlls")
      end

      -- Sharp editorial border for hover & signature popups
      vim.diagnostic.config({
        virtual_text = { prefix = "▪" },
        float = { border = "single" },
      })

      -- LSP Keybinds (active whenever a language server attaches)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          map("gd",         vim.lsp.buf.definition,      "Go to Definition")
          map("gr",         "<cmd>FzfLua lsp_references<cr>", "References (FZF)")
          map("K",          function() vim.lsp.buf.hover({ border = "single" }) end, "Hover Documentation")
          map("<leader>rn", vim.lsp.buf.rename,          "Rename Symbol")
          map("<leader>ca", vim.lsp.buf.code_action,     "Code Action")
          map("<leader>d",  function() vim.diagnostic.open_float({ border = "single" }) end, "Line Diagnostics")
        end,
      })
    end,
  },
}
