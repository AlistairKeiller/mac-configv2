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

# Install Python
brew install python
ln -s /opt/homebrew/bin/python3 /opt/homebrew/bin/python
ln -s /opt/homebrew/bin/pip3 /opt/homebrew/bin/pip

# Install alacritty
brew install --cask --no-quarantine alacritty

# Install misc packages
brew install starship uv lsd zoxide

# Install misc casks 
brew install --cask visual-studio-code orcaslicer nikitabobko/tap/aerospace modrinth font-jetbrains-mono-nerd-font raspberry-pi-imager thorium \
            discord slack raycast orbstack spotify crossover

# Configure Git
git config --global user.name "Alistair Keiller"
git config --global user.email alistair@keiller.net

# Configure ssh
mkdir -p ~/.ssh
echo "ServerAliveInterval 60" > ~/.ssh/config

# .config
mkdir -p ~/.config/
cp -r ./config/* ~/.config/

# ctrl+cmd to drag window
defaults write -g NSWindowShouldDragOnGesture YES

# whisperax (https://testflight.apple.com/join/LPVOyJZW)
# Auto hide dock, disable mouse acceleration, and shake mouse pointer to locate
# disable "Show Spotlight search" and "Show Finder search window" (https://manual.raycast.com/hotkey)
# Configure Raycast
# Install 3dconnexion
# Install Fusion
