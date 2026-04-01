if command -v code-server &> /dev/null; then
    echo "Code Server is already installed."
    exit 0
fi

curl -fsSL https://code-server.dev/install.sh | sh