alias cl="clear"
alias rcd="ranger-cd"
alias pyactivate="source .venv/bin/activate"


if [ "$(hostname)" = "truenas" ]; then
    alias code-server-tty="sudo docker exec -it code-server zsh"
fi


# ┌───────────────────────┐
# │    'show' commands    │
# └───────────────────────┘

# Shows network interfaces
alias show-interfaces="ip link show"

# This is to view artificially added latency from the add-latency function
alias show-latency="tc qdisc show"
