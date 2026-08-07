
# only if current shell session is bash and .bashrc exists
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# Ensure local bin dir exists
mkdir -p "$HOME/.local/bin"

echo ""

if [ "$(uname)" = "Linux" ]; then
    echo "Running on Linux"
elif [ "$(uname)" = "Darwin" ]; then
    echo "Running on macOS"
fi

if [ -f /etc/debian_version ]; then
    echo "Debian-based system"
elif [ -f /etc/redhat-release ]; then
    echo "RedHat-based system"
fi

echo "Logged in as $(whoami) on $(hostname) at $(date)"
echo ""

export DOTFILES="$HOME/dotfiles"

# Run in the background cause it might take a couple seconds
bash "$DOTFILES/up-to-date.bash" &
