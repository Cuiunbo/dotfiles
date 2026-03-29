# External Dependencies

`bash install` only creates symlinks for config files. The following tools need to be installed separately.

## Quick Install (macOS)

Run this one-liner to install everything:

```bash
bash setup.sh
```

Or install manually below.

## Required

| Tool | Purpose | Install |
|------|---------|---------|
| [Homebrew](https://brew.sh) | Package manager | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| [Git](https://git-scm.com) | Version control | `brew install git` |

## Terminal

| Tool | Purpose | Install |
|------|---------|---------|
| [Ghostty](https://ghostty.org) | GPU-accelerated terminal emulator | `brew install --cask ghostty` |
| [JetBrains Mono Nerd Font](https://www.nerdfonts.com) | Terminal font with icon support | `brew install --cask font-jetbrains-mono-nerd-font` |
| [Zellij](https://zellij.dev) | Terminal multiplexer | `brew install zellij` |

## Shell Plugins (git submodules, auto-installed by `bash install`)

- zsh-autosuggestions
- zsh-history-substring-search
- zsh-syntax-highlighting
- zsh-completions

## CLI Tools

| Tool | Purpose | Install |
|------|---------|---------|
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (Ctrl+R history, Ctrl+T files) | `brew install fzf` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter cd (use `z` instead of `cd`) | `brew install zoxide` |
| [thefuck](https://github.com/nvbn/thefuck) | Auto-correct previous command | `brew install thefuck` |

## Optional (nice to have)

| Tool | Purpose | Install |
|------|---------|---------|
| [bat](https://github.com/sharkdp/bat) | Better `cat` with syntax highlighting | `brew install bat` |
| [eza](https://github.com/eza-community/eza) | Better `ls` | `brew install eza` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Better `grep` | `brew install rg` |
| [fd](https://github.com/sharkdp/fd) | Better `find` | `brew install fd` |
| [delta](https://github.com/dandavid/delta) | Better `git diff` | `brew install git-delta` |
| [tldr](https://github.com/tldr-pages/tldr) | Simplified man pages | `brew install tldr` |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git | `brew install lazygit` |
