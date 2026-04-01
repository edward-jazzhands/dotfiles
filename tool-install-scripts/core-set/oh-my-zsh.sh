# ensure zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "Zsh is not installed. Please install Zsh first."
    exit 1
fi

# check if ~/.oh-my-zsh exists
if [ -d ~/.oh-my-zsh ]; then
    echo "Oh My Zsh is already installed."
    exit 0
fi

curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
