#!/usr/bin/env bash
# Lite install for an Ubuntu server used over SSH.
# Bash + starship (fish breaks ROS2's setup.bash scripts).
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run with: sudo $0"; exit 1; }
: "${SUDO_USER:?run via sudo, not as root}"

USER_HOME=$(eval echo ~"$SUDO_USER")
REPO=$(cd "$(dirname "$0")" && pwd)
run() { sudo -u "$SUDO_USER" "$@"; }

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
    curl helix bat fd-find ripgrep fzf zoxide

command -v starship >/dev/null || curl -sS https://starship.rs/install.sh | sh -s -- -y

# Ubuntu names them batcat/fdfind — alias via symlinks
run mkdir -p "$USER_HOME/.local/bin"
ln -sf "$(command -v batcat)" "$USER_HOME/.local/bin/bat"
ln -sf "$(command -v fdfind)" "$USER_HOME/.local/bin/fd"

run mkdir -p "$USER_HOME/.config"
run cp -R "$REPO/config/helix" "$USER_HOME/.config/"
run cp    "$REPO/config/starship.toml" "$USER_HOME/.config/starship.toml"

# Idempotent bashrc block
BASHRC="$USER_HOME/.bashrc"
run sed -i '/# >>> mac-config >>>/,/# <<< mac-config <<</d' "$BASHRC"
run tee -a "$BASHRC" >/dev/null <<'EOF'

# >>> mac-config >>>
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=hx
eval "$(starship init bash)"
eval "$(zoxide init --cmd cd bash)"
[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
alias cat='bat'
alias find='fd'
alias grep='rg'
# <<< mac-config <<<
EOF

echo "Done. Open a new shell or run: source ~/.bashrc"
