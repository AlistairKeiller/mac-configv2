function fish_greeting; end
fish_add_path $HOME/.cargo/bin
starship init fish | source
zoxide init fish --cmd cd | source
fzf --fish | source
set -gx EDITOR hx
set -gx BAT_THEME "Catppuccin Mocha"
alias ls='lsd'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
