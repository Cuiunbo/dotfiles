#!/usr/bin/env bash
set -e

echo "==> Installing external dependencies..."

if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> Installing terminal tools..."
brew install --cask ghostty
brew install --cask font-jetbrains-mono-nerd-font
brew install zellij

echo "==> Installing CLI tools..."
brew install fzf zoxide thefuck

echo "==> Installing optional tools..."
brew install bat eza ripgrep fd git-delta tldr lazygit

echo "==> Setting up dotfiles symlinks..."
bash install

echo ""
echo "==> Done! Open Ghostty and enjoy."
echo "    - Restart your shell or run: source ~/.zshrc"
echo "    - Spotlight: exclude ~/miniconda3 from indexing if needed"
