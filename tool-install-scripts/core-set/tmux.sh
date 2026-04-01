if command -v tmux &> /dev/null; then
    echo "Tmux is already installed."
    exit 0
fi

curl -L https://github.com/tmux/tmux-builds/releases/download/v3.6a/tmux-3.6a-linux-x86_64.tar.gz \
  | tar -xz -C "$HOME/.local/bin"