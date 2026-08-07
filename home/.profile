
# only if current shell session is bash and .bashrc exists
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# zsh sources this file and the .zshrc file automatically,
# so we don't need to do anything here.

# Ensure local bin dir exists
mkdir -p "$HOME/.local/bin"

export DEBEMAIL="ed.jazzhands@gmail.com"
export DEBFULLNAME="Brent Lidstone"

# Add $HOME/.local/bin to the path
export PATH="$HOME/.local/bin:$PATH"

# Add $HOME/bin to the path
export PATH="$HOME/bin:$PATH"

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

export DOTFILES="$HOME/dotfiles"

# Run in the background cause it might take a couple seconds
( bash "$DOTFILES/up-to-date.bash" ) 2>/dev/null &
disown
