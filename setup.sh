#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

installed=0
skipped=0
OS="$(uname -s)"

skip_or_install() {
    local cmd="$1"
    local name="$2"
    if command -v "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $name"
        skipped=$((skipped + 1))
        return 1
    fi
    return 0
}

install_done() {
    installed=$((installed + 1))
}

echo ""
echo "=== Dotfiles Setup ==="

if [ "$OS" = "Darwin" ]; then
    echo -e "${BLUE}Platform: macOS${NC}"
else
    echo -e "${BLUE}Platform: Linux$([ -f /etc/os-release ] && . /etc/os-release && echo " ($NAME)")${NC}"
fi

# ============================================================
# macOS
# ============================================================
if [ "$OS" = "Darwin" ]; then

    if ! command -v brew &>/dev/null; then
        echo -e "\n==> Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "\n${GREEN}✓${NC} Homebrew"
    fi

    echo -e "\n==> Terminal"

    if [ -d "/Applications/Ghostty.app" ]; then
        echo -e "  ${GREEN}✓${NC} ghostty"
        skipped=$((skipped + 1))
    else
        echo -e "  ${YELLOW}→${NC} Installing ghostty..."
        brew install --cask ghostty
        install_done
    fi

    if ls ~/Library/Fonts/JetBrainsMonoNerdFont* &>/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} nerd-font"
        skipped=$((skipped + 1))
    else
        echo -e "  ${YELLOW}→${NC} Installing nerd-font..."
        brew install --cask font-jetbrains-mono-nerd-font
        install_done
    fi

    for item in zellij fzf zoxide thefuck bat eza ripgrep fd git-delta tldr lazygit; do
        cmd="$item"
        case "$item" in
            ripgrep)   cmd="rg" ;;
            git-delta) cmd="delta" ;;
            fd)        cmd="fd" ;;
        esac
        if skip_or_install "$cmd" "$item"; then
            echo -e "  ${YELLOW}→${NC} Installing $item..."
            brew install "$item"
            install_done
        fi
    done

# ============================================================
# Linux (Ubuntu)
# ============================================================
else

    echo -e "\n==> Updating package list..."
    sudo apt-get update -qq

    echo -e "\n==> CLI Tools"

    APT_TOOLS=(fzf bat ripgrep fd-find)
    for pkg in "${APT_TOOLS[@]}"; do
        cmd="$pkg"
        case "$pkg" in
            bat)      cmd="batcat" ;;
            ripgrep)  cmd="rg" ;;
            fd-find)  cmd="fdfind" ;;
        esac
        if skip_or_install "$cmd" "$pkg"; then
            echo -e "  ${YELLOW}→${NC} Installing $pkg..."
            sudo apt-get install -y -qq "$pkg"
            install_done
        fi
    done

    # bat: Ubuntu installs as 'batcat', create alias
    if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
        mkdir -p ~/.local/bin
        ln -sf "$(which batcat)" ~/.local/bin/bat
        echo -e "  ${GREEN}✓${NC} bat -> batcat (linked)"
    fi

    # fd: Ubuntu installs as 'fdfind', create alias
    if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        mkdir -p ~/.local/bin
        ln -sf "$(which fdfind)" ~/.local/bin/fd
        echo -e "  ${GREEN}✓${NC} fd -> fdfind (linked)"
    fi

    # zoxide (install script)
    if skip_or_install "zoxide" "zoxide"; then
        echo -e "  ${YELLOW}→${NC} Installing zoxide..."
        curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        install_done
    fi

    # eza (from official repo)
    if skip_or_install "eza" "eza"; then
        echo -e "  ${YELLOW}→${NC} Installing eza..."
        sudo apt-get install -y -qq eza 2>/dev/null || {
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo apt-get update -qq && sudo apt-get install -y -qq eza
        }
        install_done
    fi

    # lazygit (from GitHub releases)
    if skip_or_install "lazygit" "lazygit"; then
        echo -e "  ${YELLOW}→${NC} Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -sSLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz" 2>/dev/null \
            || curl -sSLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm -f lazygit lazygit.tar.gz
        install_done
    fi

    # delta (from GitHub releases)
    if skip_or_install "delta" "git-delta"; then
        echo -e "  ${YELLOW}→${NC} Installing git-delta..."
        ARCH=$(dpkg --print-architecture)
        DELTA_DEB=$(curl -s https://api.github.com/repos/dandavella/delta/releases/latest 2>/dev/null \
            || curl -s https://api.github.com/repos/dandavid/delta/releases/latest 2>/dev/null \
            | grep -Po "\"browser_download_url\": \"\K.*${ARCH}\.deb(?=\")" | head -1)
        if [ -n "$DELTA_DEB" ]; then
            curl -sSLo /tmp/delta.deb "$DELTA_DEB" && sudo dpkg -i /tmp/delta.deb && rm -f /tmp/delta.deb
        else
            echo -e "  ${YELLOW}!${NC} delta: install manually from https://github.com/dandavella/delta/releases"
        fi
        install_done
    fi

    # Make sure ~/.local/bin is in PATH
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.shell_local_after
        echo -e "  ${GREEN}✓${NC} Added ~/.local/bin to PATH"
    fi
fi

# ============================================================
# Dotfiles symlinks (cross-platform)
# ============================================================
echo -e "\n==> Setting up dotfiles symlinks..."
bash install

echo ""
echo "=== Done! ==="
echo -e "  Installed: ${GREEN}${installed}${NC}  Skipped: ${skipped}"
echo ""
if [ "$OS" = "Darwin" ]; then
    echo "  Next steps:"
    echo "    1. Open Ghostty"
    echo "    2. Run: source ~/.zshrc"
else
    echo "  Next steps:"
    echo "    1. Run: source ~/.zshrc"
    echo "    2. Use 'z' instead of 'cd', Ctrl+R for fuzzy history"
fi
echo ""
