-- Neovim config, rebuilt from scratch on stock Neovim (0.12+).

-- Plugins, managed by the built-in vim.pack (versions pinned in nvim-pack-lock.json).
vim.pack.add({
  "https://github.com/scottmckendry/cyberdream.nvim",
})

-- Colorscheme. Light/dark follows the OS through the terminal: Nvim queries the
-- terminal's background at startup and re-queries it whenever the terminal
-- reports a theme change (DEC mode 2031), updating 'background'. That reloads
-- the colorscheme, and variant = "auto" picks cyberdream's light or dark palette
-- from 'background'. Don't set 'background' yourself: doing so turns this off.
require("cyberdream").setup({ variant = "auto" })
vim.cmd.colorscheme("cyberdream")
