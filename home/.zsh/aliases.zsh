# Safety aliases
alias rm="rm -i"    # Ask for confirmation before deleting files
alias cp="cp -i"    # Ask for confirmation before overwriting files
alias mv="mv -i"    # Ask for confirmation before overwriting files

# Colorized outputs
alias ls="ls --color=auto"   # Colorize directory listings (use -G on macOS)
alias grep="grep --color=auto" # Colorize search matches

# Quick navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# shortcuts
alias cl="clear"
alias rcd="ranger-cd"
alias pyactivate="source .venv/bin/activate"

if [ "$(hostname)" = "truenas" ]; then
    alias code-server-tty="docker exec -it code-server zsh"
fi

# ┌───────────────────────┐
# │    'show' commands    │
# └───────────────────────┘

# Shows network interfaces
alias show-interfaces="ip link show"

# This is to view artificially added latency from the add-latency function
alias show-latency="tc qdisc show"
