vim.o.number = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.o.hlsearch = false
vim.opt.wrap = true

vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false
vim.o.relativenumber = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.cursorline = true
vim.o.termguicolors = true

vim.g.mapleader = ' '
vim.opt.smarttab = true
vim.opt.wildignore = { '*.o', '*.a', '_pycache_' }
vim.opt.listchars = { space = '_', tab = '>~' }
vim.opt.formatoptions = { n = true, j = true, t = true }

vim.keymap.set({'n', 'x'}, 'gy', '"+y')
vim.keymap.set({'n', 'x'}, 'gp', '"p')
vim.cmd.colorscheme("habamax")
vim.cmd.highlight({ "Error", "guibg=red" })
vim.cmd.highlight({ "link", "Warning", "Error" })



