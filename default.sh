#!/bin/zsh
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with: sudo $0"; exit 1; }
: "${SUDO_USER:?run via sudo, not as root}"

USER_HOME=$(eval echo ~$SUDO_USER)
FISH=/opt/homebrew/bin/fish
run() { sudo -u "$SUDO_USER" env PATH="/opt/homebrew/bin:$PATH" "$@"; }

# Homebrew
run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Packages
run brew install fish starship lsd zoxide gh uv rustup \
                bat fd ripgrep git-delta fzf
run brew install --cask ghostty zed slack orbstack google-chrome discord \
                        font-jetbrains-mono-nerd-font

# Fish as login shell
grep -qxF $FISH /etc/shells || echo $FISH >> /etc/shells
chsh -s $FISH $SUDO_USER

# Rust
run /opt/homebrew/bin/rustup default stable

# Dotfiles + git
run cp -R ./config/. $USER_HOME/.config/
run touch $USER_HOME/.hushlogin
run git config --global user.name "Alistair Keiller"
run git config --global user.email alistair@keiller.net
run git config --global core.pager delta
run git config --global interactive.diffFilter "delta --color-only"
run git config --global delta.navigate true
run git config --global delta.syntax-theme "Catppuccin Mocha"
run gh auth status &>/dev/null || run gh auth login

# Wallpapers — remove images too small to fill the display without upscaling
run uv run --with pillow --python 3.14 "$(dirname $0)/delete_small_walls.py"

# macOS defaults
run defaults write -g AppleMenuBarVisibleInFullscreen -bool false
run defaults write -g NSWindowShouldDragOnGesture -bool true
run defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
run defaults write -g CGDisableCursorLocationMagnification -bool true
run defaults write -g com.apple.mouse.linear -bool true
run defaults write com.apple.dock autohide -bool true
run defaults write com.apple.dock show-recents -bool false
run killall Dock 2>/dev/null || true

cat <<'EOF'

Done. Manual steps:
  • System Settings → Keyboard → Keyboard Shortcuts → Spotlight change ⌘Space from "Show spotlight search" to "Show apps".
  • Install Tailscale and Wipr from the App Store.
EOF
