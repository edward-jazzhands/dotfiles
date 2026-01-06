
# only if current shell session is bash:
if [ -n "$BASH_VERSION" ]; then
    # source the .bashrc file if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# Add $HOME/.local/bin to the path
export PATH="$HOME/.local/bin:$PATH"

# Add $HOME/bin to the path
export PATH="$HOME/bin:$PATH"