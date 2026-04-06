#!/bin/zsh
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo"
  exit 1
fi

REAL_USER=$SUDO_USER
REAL_HOME=$(eval echo ~$SUDO_USER)

# Install Homebrew
sudo -u $REAL_USER /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Install brew packages
sudo -u $REAL_USER /opt/homebrew/bin/brew install fish \
    rustup-init \
    starship lsd zoxide uv bat hyperfine dust tokei gh \
    zed alacritty nikitabobko/tap/aerospace font-jetbrains-mono-nerd-font \
    google-chrome discord slack orbstack
# setup fish
sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish $REAL_USER
sudo -u $REAL_USER /opt/homebrew/bin/fish -c "fish_add_path /opt/homebrew/bin"
# setup rust
sudo -u $REAL_USER /opt/homebrew/bin/rustup-init -y --profile complete
# .config
mkdir -p $REAL_HOME/.config/
sudo -u $REAL_USER cp -r ./config/* $REAL_HOME/.config/
sudo -u $REAL_USER touch $REAL_HOME/.hushlogin
# Configure git
sudo -u $REAL_USER git config --global user.name "Alistair Keiller"
sudo -u $REAL_USER git config --global user.email alistair@keiller.net
# Configure git authentication
sudo -u $REAL_USER /opt/homebrew/bin/gh auth login
# ctrl+cmd to drag window
sudo -u $REAL_USER defaults write -g NSWindowShouldDragOnGesture -bool "true"
# Auto hide dock (https://macos-defaults.com/dock/autohide.html)
sudo -u $REAL_USER defaults write com.apple.dock "autohide" -bool "true"
# Disable mouse acceleration (https://macos-defaults.com/mouse/linear.html)
sudo -u $REAL_USER defaults write NSGlobalDomain com.apple.mouse.linear -bool "true"
# Disable shake mouse pointer to locate
sudo -u $REAL_USER defaults write $REAL_HOME/Library/Preferences/.GlobalPreferences CGDisableCursorLocationMagnification -bool "true"
# Install tailscale and wipr
