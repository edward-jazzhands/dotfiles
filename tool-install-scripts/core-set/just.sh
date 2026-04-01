if command -v just &> /dev/null; then
    echo "Just is already installed."
    exit 0
fi

# Just
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to "$HOME/.local/bin"
