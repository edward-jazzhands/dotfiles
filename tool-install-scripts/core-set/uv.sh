if command -v uv &> /dev/null; then
    echo "UV is already installed."
    exit 0
fi

curl -fsSL https://astral.sh/uv/install.sh | sh
