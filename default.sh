#!/bin/zsh
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Packages
brew install fish starship lsd zoxide git gh uv \
                bat fd ripgrep git-delta fzf
brew install --cask ghostty zed slack orbstack google-chrome discord \
                        font-jetbrains-mono-nerd-font

# Fish as login shell
grep -qxF /opt/homebrew/bin/fish /etc/shells || echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
sudo chsh -s /opt/homebrew/bin/fish "$USER"

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Dotfiles + git
mkdir -p ~/.config
cp -R ./config/. ~/.config/
touch ~/.hushlogin
git config --global user.name "Alistair Keiller"
git config --global user.email alistair@keiller.net
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.syntax-theme "Catppuccin Mocha"
gh auth status &>/dev/null || gh auth login

# Wallpapers — remove images too small to fill the display without upscaling
uv run --with pillow --python 3.14 delete_small_walls.py

# macOS defaults
defaults write -g NSWindowShouldDragOnGesture -bool true
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g CGDisableCursorLocationMagnification -bool true
defaults write com.apple.dock show-recents -bool false

cat <<'EOF'

Done. Manual steps:
  • System Settings → Keyboard → Keyboard Shortcuts → Spotlight change ⌘Space from "Show spotlight search" to "Show apps".
  • Install Tailscale and Wipr from the App Store.
EOF
