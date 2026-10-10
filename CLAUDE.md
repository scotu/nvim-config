# CLAUDE.md

Personal Neovim config on stock Neovim 0.12+ with the built-in `vim.pack`; everything
is in `init.lua`. Language tools come from Homebrew via the dotfiles repo
(`~/.local/share/chezmoi`), whose `CLAUDE.md` describes how this repo is synced.

## Change workflow

Every change goes through a PR. Before the first edit, follow the **"Change
workflow"** section of `~/.local/share/chezmoi/CLAUDE.md`: sync gate, branch, PR,
merge only when asked.

## Testing a change

Run Neovim headless against the edited config, e.g.
`nvim --headless "+checkhealth vim.pack" +qa` for startup errors, or open a sample file
and inspect `vim.lsp.get_clients()` / `vim.diagnostic.get()`. A new language usually
also needs a Brewfile entry in the dotfiles repo, which is its own PR.
