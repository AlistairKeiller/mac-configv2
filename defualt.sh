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
run brew install fish starship lsd zoxide gh uv rustup-init \
                 lua jq switchaudio-osx \
                 FelixKratz/formulae/{sketchybar,borders}
run brew install --cask ghostty zed slack orbstack google-chrome discord \
                 font-jetbrains-mono-nerd-font font-sketchybar-app-font sf-symbols
run brew install --no-quarantine --cask nikitabobko/tap/aerospace \
                                        unsecretised/tap/rustcast

# SketchyBar — FelixKratz dotfiles + SbarLua
run rm -rf /tmp/SbarLua /tmp/felixkratz $USER_HOME/.config/sketchybar
run git clone --depth 1 https://github.com/FelixKratz/SbarLua /tmp/SbarLua
run make -C /tmp/SbarLua install
run git clone --depth 1 https://github.com/FelixKratz/dotfiles /tmp/felixkratz
run cp -R /tmp/felixkratz/.config/sketchybar $USER_HOME/.config/

# Fish as login shell
grep -qxF $FISH /etc/shells || echo $FISH >> /etc/shells
chsh -s $FISH $SUDO_USER

# Rust
run /opt/homebrew/bin/rustup-init -y --profile complete --no-modify-path

# Dotfiles + git
run cp -R ./config/. $USER_HOME/.config/
run touch $USER_HOME/.hushlogin
run git config --global user.name "Alistair Keiller"
run git config --global user.email alistair@keiller.net
run gh auth status &>/dev/null || run gh auth login

# Ricing services
run brew services start sketchybar
run brew services start borders

# macOS defaults
run defaults write -g NSWindowShouldDragOnGesture -bool true
run defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
run defaults write -g CGDisableCursorLocationMagnification -bool true
run defaults write -g com.apple.mouse.linear -bool true
run defaults write com.apple.dock autohide -bool true
run killall Dock 2>/dev/null || true

cat <<'EOF'

Done. Manual steps:
  • Open AeroSpace and RustCast once — grant Accessibility permission.
  • Disable Spotlight hotkey in System Settings → Keyboard (so RustCast can take ⌘Space).
  • Install Tailscale and Wipr from the App Store.
EOF
