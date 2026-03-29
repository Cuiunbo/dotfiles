#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

installed=0
skipped=0

check_and_install() {
    local cmd="$1"
    local pkg="$2"
    local type="${3:-formula}"

    if command -v "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $pkg (already installed)"
        skipped=$((skipped + 1))
    else
        echo -e "  ${YELLOW}→${NC} Installing $pkg..."
        if [ "$type" = "cask" ]; then
            brew install --cask "$pkg"
        else
            brew install "$pkg"
        fi
        installed=$((installed + 1))
    fi
}

check_and_install_cask() {
    local app_path="$1"
    local pkg="$2"

    if [ -d "$app_path" ] || brew list --cask "$pkg" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $pkg (already installed)"
        skipped=$((skipped + 1))
    else
        echo -e "  ${YELLOW}→${NC} Installing $pkg..."
        brew install --cask "$pkg"
        installed=$((installed + 1))
    fi
}

check_font() {
    local pattern="$1"
    local pkg="$2"

    if ls ~/Library/Fonts/$pattern* &>/dev/null || ls /Library/Fonts/$pattern* &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $pkg (already installed)"
        skipped=$((skipped + 1))
    else
        echo -e "  ${YELLOW}→${NC} Installing $pkg..."
        brew install --cask "$pkg"
        installed=$((installed + 1))
    fi
}

echo ""
echo "=== Dotfiles Setup ==="
echo ""

# Homebrew
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo -e "${GREEN}✓${NC} Homebrew"
fi

# Terminal
echo ""
echo "==> Terminal"
check_and_install_cask "/Applications/Ghostty.app" "ghostty"
check_font "JetBrainsMonoNerdFont" "font-jetbrains-mono-nerd-font"
check_and_install "zellij" "zellij"

# CLI tools (required)
echo ""
echo "==> CLI Tools"
check_and_install "fzf" "fzf"
check_and_install "zoxide" "zoxide"
check_and_install "thefuck" "thefuck"

# CLI tools (optional but recommended)
echo ""
echo "==> Optional Tools"
check_and_install "bat" "bat"
check_and_install "eza" "eza"
check_and_install "rg" "ripgrep"
check_and_install "fd" "fd"
check_and_install "delta" "git-delta"
check_and_install "tldr" "tldr"
check_and_install "lazygit" "lazygit"

# Dotfiles symlinks
echo ""
echo "==> Setting up dotfiles symlinks..."
bash install

echo ""
echo "=== Done! ==="
echo -e "  Installed: ${GREEN}${installed}${NC}  Skipped: ${skipped}"
echo ""
echo "  Next steps:"
echo "    1. Open Ghostty"
echo "    2. Run: source ~/.zshrc"
echo ""
