#!/bin/zsh

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > /Users/alistairkeiller/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install fish
brew install fish
sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish
fish -c "fish_add_path /opt/homebrew/bin"

# Install rust
brew install rustup-init
rustup-init -y --profile complete

# Install alacritty
brew install --cask --no-quarantine alacritty

# Install misc packages
brew install starship lsd zoxide uv bat hyperfine dust tokei gh

# Install misc casks 
brew install --cask visual-studio-code orcaslicer nikitabobko/tap/aerospace font-jetbrains-mono-nerd-font alex313031-thorium rustdesk raspberry-pi-imager kdenlive \
            discord slack raycast orbstack spotify crossover steam

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

# disable "Show Spotlight search" and "Show Finder search window" (https://manual.raycast.com/hotkey)
# Configure Raycast
# Install Fusion, tailscale, and wipr

