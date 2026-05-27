#!/bin/zsh
set -euo pipefail

cp -R ./config/. "$HOME/.config/"

env HOMEBREW_SERVICES_NO_DOMAIN_WARNING=1 brew services restart sketchybar
env HOMEBREW_SERVICES_NO_DOMAIN_WARNING=1 brew services restart borders
/opt/homebrew/bin/aerospace reload-config 2>/dev/null || true
