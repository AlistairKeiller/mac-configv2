function fish_greeting
end

if status is-interactive
    starship init fish | source
    zoxide init fish | source
    alias ls='lsd'
    alias l='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'
    alias cd='z'
end