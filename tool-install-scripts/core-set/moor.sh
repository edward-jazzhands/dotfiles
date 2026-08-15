# this is a binary, so we dont need to extract anything:
# https://github.com/walles/moor/releases/download/v2.15.0/moor-v2.15.0-linux-amd64

if command -v moor &> /dev/null; then
    echo "Moor is already installed."
    exit 0
fi

curl -fsSL https://github.com/walles/moor/releases/download/v2.15.0/moor-v2.15.0-linux-amd64 \
  -o "$HOME/.local/bin/moor"
chmod +x "$HOME/.local/bin/moor"