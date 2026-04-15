if command -v lazygit &> /dev/null; then
    echo "Lazygit is already installed."
    exit 0
fi

curl -L https://github.com/jesseduffield/lazygit/releases/download/v0.61.1/lazygit_0.61.1_linux_x86_64.tar.gz \
  | tar -xz -C "$HOME/.local/bin"