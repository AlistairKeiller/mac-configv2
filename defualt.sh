#!/bin/zsh

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install brew packages
/opt/homebrew/bin/brew install fish \
    rustup-init \
    starship lsd zoxide uv bat hyperfine dust tokei gh \
    ghostty visual-studio-code nikitabobko/tap/aerospace font-jetbrains-mono-nerd-font google-chrome \
    discord slack orbstack spotify

# setup fish
sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish
fish -c "fish_add_path /opt/homebrew/bin"

# setup rust
rustup-init -y --profile complete

# .config
mkdir -p ~/.config/
cp -r ./config/* ~/.config/
touch ~/.hushlogin

# Configure git
git config --global user.name "Alistair Keiller"
git config --global user.email alistair@keiller.net

# Configure git authentication
gh auth login

# ctrl+cmd to drag window
defaults write -g NSWindowShouldDragOnGesture -bool "true"

# Auto hide dock (https://macos-defaults.com/dock/autohide.html)
defaults write com.apple.dock "autohide" -bool "true"

# Disable mouse acceleration (https://macos-defaults.com/mouse/linear.html)
defaults write NSGlobalDomain com.apple.mouse.linear -bool "true"

# Disable shake mouse pointer to locate
defaults write ~/Library/Preferences/.GlobalPreferences CGDisableCursorLocationMagnification -bool "true"

# Install tailscale and wipr
