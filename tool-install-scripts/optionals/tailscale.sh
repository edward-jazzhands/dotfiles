if command -v tailscale &> /dev/null; then
    echo "Tailscale is already installed."
    exit 0
fi

# NOTE: This might require sudo I am not sure
curl -fsSL https://tailscale.com/install.sh | sh