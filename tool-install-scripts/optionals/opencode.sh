if command -v opencode &> /dev/null; then
    echo "Opencode is already installed."
    exit 0
fi

curl -fsSL https://opencode.ai/install | bash