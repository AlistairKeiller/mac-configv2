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
                 lua jq switchaudio-osx \
                 FelixKratz/formulae/{sketchybar,borders}
run brew install --cask ghostty zed slack orbstack google-chrome discord \
                        font-jetbrains-mono-nerd-font font-sketchybar-app-font sf-symbols \
                        nikitabobko/tap/aerospace unsecretised/tap/rustcast

# Strip Gatekeeper quarantine on unsigned apps (replaces removed --no-quarantine flag)
run xattr -dr com.apple.quarantine /Applications/AeroSpace.app || true
run xattr -dr com.apple.quarantine /Applications/RustCast.app  || true

# SbarLua (compiled C module required by FelixKratz sketchybar config)
run rm -rf /tmp/SbarLua
run git clone --depth 1 https://github.com/FelixKratz/SbarLua /tmp/SbarLua
run make -C /tmp/SbarLua install

# Fish as login shell
grep -qxF $FISH /etc/shells || echo $FISH >> /etc/shells
chsh -s $FISH $SUDO_USER

# Rust
run /opt/homebrew/bin/rustup set profile complete
run /opt/homebrew/bin/rustup default stable

# Dotfiles + git
run cp -R ./config/. $USER_HOME/.config/
run touch $USER_HOME/.hushlogin
run git config --global user.name "Alistair Keiller"
run git config --global user.email alistair@keiller.net
run gh auth status &>/dev/null || run gh auth login

# Wallpapers — remove images too small to fill the display without upscaling
run python3 "$(dirname $0)/delete_small_walls.py"

# Ricing services
run brew services start sketchybar
run brew services start borders

# macOS defaults
run defaults write -g AppleMenuBarVisibleInFullscreen -bool false
run defaults write -g NSWindowShouldDragOnGesture -bool true
run defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
run defaults write -g CGDisableCursorLocationMagnification -bool true
run defaults write -g com.apple.mouse.linear -bool true
run defaults write com.apple.dock autohide -bool true
run killall Dock 2>/dev/null || true

cat <<'EOF'

Done. Manual steps:
  • Log out and back in (picks up fish + AeroSpace start-at-login).
  • Open OrbStack once to finish its VM setup.
  • Grant Accessibility to AeroSpace and RustCast on first launch.
  • System Settings → Keyboard → Spotlight: uncheck the hotkey (frees ⌘Space for RustCast).
  • System Settings → Desktop & Dock: uncheck "Displays have separate Spaces".
  • Install Tailscale and Wipr from the App Store.
EOF
