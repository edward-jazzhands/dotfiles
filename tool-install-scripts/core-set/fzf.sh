if command -v fzf &> /dev/null; then
    echo "fzf is already installed."
    exit 0
fi

# FZF
curl -L https://github.com/junegunn/fzf/releases/download/v0.67.0/fzf-0.67.0-linux_amd64.tar.gz \
  | tar -xz -C "$HOME/.local/bin"
