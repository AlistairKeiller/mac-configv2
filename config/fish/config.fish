function fish_greeting; end
fish_add_path $HOME/.cargo/bin
starship init fish | source
zoxide init fish --cmd cd | source
alias ls='lsd'
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
