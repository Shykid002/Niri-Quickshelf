-- ── Leader Key (must be set before lazy.nvim loads) ───────
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ── Core Options ──────────────────────────────────────────
local opt = vim.opt

-- Visual & Editorial Polish
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.showmode = false             -- Mode is shown in statusline
opt.fillchars = { eob = " " }    -- Hide ~ on empty lines for a clean paper page look
opt.laststatus = 3               -- Global statusline across splits

-- Custom Cursor Shapes (uses `Cursor` highlight from colors/rice.lua)
opt.guicursor = table.concat({
  "n-v-c:block-Cursor",
  "i-ci-ve:ver25-Cursor",
  "r-cr:hor20-Cursor",
  "o:hor50-Cursor",
  "a:blinkwait700-blinkoff400-blinkon250",
}, ",")

-- Indentation & Tabs
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Splits & Windows
opt.splitright = true
opt.splitbelow = true

-- Files, Undo & Clipboard
opt.undofile = true              -- Persistent undo across sessions
opt.swapfile = false
opt.backup = false
opt.clipboard = "unnamedplus"    -- Sync with Wayland system clipboard (wl-clipboard)
opt.updatetime = 250
opt.timeoutlen = 300

-- ── Load Paper & Ink Rice Colorscheme + Auto-Reload Watcher ──
pcall(vim.cmd.colorscheme, "rice")

local rice_color_file = vim.fn.stdpath("config") .. "/colors/rice.lua"
local watcher = (vim.uv or vim.loop).new_fs_event()
if watcher and vim.fn.filereadable(rice_color_file) == 1 then
  watcher:start(rice_color_file, {}, vim.schedule_wrap(function(err)
    if not err then
      pcall(vim.cmd.colorscheme, "rice")
    end
  end))
end

-- ── Essential Keymaps ─────────────────────────────────────
local map = vim.keymap.set

-- Clear search highlight with Esc
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Move between splits with Ctrl + h/j/k/l
map("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

-- Resize splits with Ctrl + Arrow keys
map("n", "<C-Up>",    "<cmd>resize +2<CR>",          { desc = "Increase window height" })
map("n", "<C-Down>",  "<cmd>resize -2<CR>",          { desc = "Decrease window height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Keep visual selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move selected lines up/down in Visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

-- Quick save & quit
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window" })

-- ── Highlight on Yank ─────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

-- ── Bootstrap lazy.nvim & Auto-Import lua/plugins/*.lua ───
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Make sure ~/.config/nvim/lua/plugins exists so lazy.nvim never warns on an empty folder
vim.fn.mkdir(vim.fn.stdpath("config") .. "/lua/plugins", "p")

require("lazy").setup({
  spec = {
    -- Automatically reads EVERY .lua file you put inside ~/.config/nvim/lua/plugins/
    { import = "plugins" },
  },
  install = {
    colorscheme = { "rice" },
  },
  ui = {
    border = "single", -- Sharp editorial corners matching your rice
  },
  change_detection = {
    notify = false,
  },
})

