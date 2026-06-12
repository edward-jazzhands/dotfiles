alias cl="clear"
alias rcd="ranger-cd"
alias pyactivate="source .venv/bin/activate"

# To export extensions list:
# code-server --list-extensions > extensions.txt
if command -v code-server &> /dev/null; then
    alias sync-extensions="cat $DOTFILES/openvsx-extensions.txt | xargs -L 1 code-server --install-extension"


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
