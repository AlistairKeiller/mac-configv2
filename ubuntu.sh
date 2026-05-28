#!/usr/bin/env bash
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run with: sudo $0"; exit 1; }
: "${SUDO_USER:?run via sudo, not as root}"

USER_HOME=$(eval echo ~"$SUDO_USER")
REPO=$(cd "$(dirname "$0")" && pwd)
run() { sudo -u "$SUDO_USER" "$@"; }

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
    curl fish helix bat fd-find ripgrep fzf lsd zoxide

command -v starship >/dev/null || curl -sS https://starship.rs/install.sh | sh -s -- -y

run mkdir -p "$USER_HOME/.local/bin"
ln -sf "$(command -v batcat)" "$USER_HOME/.local/bin/bat"
ln -sf "$(command -v fdfind)" "$USER_HOME/.local/bin/fd"

run mkdir -p "$USER_HOME/.config"
run cp -R "$REPO/config/fish"  "$USER_HOME/.config/"
run cp -R "$REPO/config/helix" "$USER_HOME/.config/"
run cp    "$REPO/config/starship.toml" "$USER_HOME/.config/starship.toml"
run sed -i '/alias tailscale=/d' "$USER_HOME/.config/fish/config.fish"

chsh -s /usr/bin/fish "$SUDO_USER"
echo "Done. Log out and back in."
