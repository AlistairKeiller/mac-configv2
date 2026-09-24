#!/bin/zsh
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Packages
brew install fish starship lsd zoxide git gh uv helix bat fd ripgrep git-delta fzf
brew install --cask ghostty zed orbstack helium-browser discord font-jetbrains-mono-nerd-font

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
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.dark true
git config --global merge.conflictStyle zdiff3
gh auth status &>/dev/null || gh auth login

# Wallpapers — filter resolution and suspected AI imagery
git clone https://github.com/harilvfs/wallpapers
uv run delete_small_walls.py

# macOS defaults
defaults write -g NSWindowShouldDragOnGesture -bool true
defaults write -g CGDisableCursorLocationMagnification -bool true
defaults write com.apple.dock show-recents -bool false

cat <<'EOF'

Done. Manual steps:
- Install Tailscale and Wipr from the App Store.
- Enable touchid for sudo
    - sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
    - sudo hx /etc/pam.d/sudo_local # uncomment
EOF
