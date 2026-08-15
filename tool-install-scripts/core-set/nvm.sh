# look for .nvm folder
if [ -d ~/.nvm ]; then
    echo "NVM is already installed."
    exit 0
fi

# check nvm command
if command -v nvm &> /dev/null; then
    echo "NVM is already installed."
    exit 0
fi

curl -fsSL -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash