# look for .nvm folder
if [ -d ~/.nvm ]; then
    echo "NVM is already installed."
    exit 0
fi

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash