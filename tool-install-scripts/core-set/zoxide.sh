if command -v zoxide &> /dev/null; then
    echo "Zoxide is already installed."
    exit 0
fi

# Zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
