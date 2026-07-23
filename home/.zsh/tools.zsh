# Homebrew
# Note: There is a Homebrew plugin for oh-my-zsh, but it includes a
# bunch of aliases that I don't want.
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Zoxide
eval "$(zoxide init bash)"


# check if nvm is installed
if [ -f "$HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
