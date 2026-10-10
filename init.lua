-- Neovim config, rebuilt from scratch on stock Neovim (0.12+).
--
-- Language tools (basedpyright, ruff, tsc, prettier, tree-sitter-cli) come from
-- Homebrew via the chezmoi Brewfile, not from inside Neovim.

-- Plugin hooks. Defined before vim.pack.add so they also fire on first install.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    -- nvim-treesitter only works with the parser versions it pins: rebuild them on update.
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

-- Plugins, managed by the built-in vim.pack (versions pinned in nvim-pack-lock.json).
vim.pack.add({
  "https://github.com/scottmckendry/cyberdream.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/stevearc/conform.nvim",
  -- v1 tags ship a prebuilt fuzzy matcher; main (v2) needs a Rust toolchain to build it.
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1") },
})

-- Colorscheme. Light/dark follows the OS through the terminal: Nvim queries the
-- terminal's background at startup and re-queries it whenever the terminal
-- reports a theme change (DEC mode 2031), updating 'background'. That reloads
-- the colorscheme, and variant = "auto" picks cyberdream's light or dark palette
-- from 'background'. Don't set 'background' yourself: doing so turns this off.
require("cyberdream").setup({ variant = "auto" })
vim.cmd.colorscheme("cyberdream")

-- Treesitter: parsers for syntax highlighting. install() is a no-op for
-- parsers already present, and builds missing ones in the background.
require("nvim-treesitter").install({ "python", "javascript", "typescript", "tsx" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function()
    -- pcall: the parser may still be building on a fresh install.
    pcall(vim.treesitter.start)
  end,
})

-- Completion
require("blink.cmp").setup({})

-- Language servers. nvim-lspconfig supplies the server configs; these are the
-- local tweaks. Default keymaps come from Nvim itself: K (hover), grn (rename),
-- gra (code action), grr (references), gri (implementation), gO (symbols),
-- [d / ]d (diagnostics). Go-to-definition is CTRL-].

-- Prefer the project's own .venv: its ruff (so linting matches the project's
-- pinned version) and its Python (so basedpyright sees the installed packages).
local function venv_bin(root, bin)
  local path = root and vim.fs.joinpath(root, ".venv", "bin", bin)
  return path and vim.fn.executable(path) == 1 and path or nil
end

vim.lsp.config("ruff", {
  cmd = function(dispatchers, config)
    local ruff = venv_bin(config.root_dir, "ruff") or "ruff"
    return vim.lsp.rpc.start({ ruff, "server" }, dispatchers, { cwd = config.root_dir })
  end,
})

vim.lsp.config("basedpyright", {
  before_init = function(_, config)
    local python = venv_bin(config.root_dir, "python")
    if python then
      config.settings.python = vim.tbl_extend("force", config.settings.python or {}, { pythonPath = python })
    end
  end,
})

-- tsc is TypeScript 7's built-in server; lspconfig prefers node_modules/.bin/tsc when it's 7+.
vim.lsp.enable({ "basedpyright", "ruff", "tsc" })

vim.diagnostic.config({ virtual_text = true })

-- Formatting on save. Python has no formatter listed, so it falls back to the
-- ruff language server; prettier is taken from node_modules/.bin when present.
require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
  },
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = { timeout_ms = 1000 },
})
