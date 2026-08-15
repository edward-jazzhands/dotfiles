if command -v caddy &> /dev/null; then
    echo "Caddy is already installed."
    exit 0
fi

curl -fsSL https://github.com/caddyserver/caddy/releases/download/v2.11.4/caddy_2.11.4_linux_amd64.tar.gz \
  | tar -xz -C "$HOME/.local/bin"
