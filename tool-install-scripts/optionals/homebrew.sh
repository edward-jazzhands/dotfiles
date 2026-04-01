if command -v brew &> /dev/null; then
    echo "Homebrew is already installed."
    exit 0
fi

curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

# brew tools:
# lazygit