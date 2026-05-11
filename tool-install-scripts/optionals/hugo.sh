if command -v hugo &> /dev/null; then
    echo "Hugo is already installed."
    exit 0
fi

curl -L -o /tmp/hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v0.161.1/hugo_0.161.1_Linux-64bit.tar.gz && \
  mkdir -p /tmp/hugo && tar -xzf /tmp/hugo.tar.gz -C /tmp/hugo && rm /tmp/hugo.tar.gz

cp -r "/tmp/hugo/hugo" "$HOME/.local/bin" 
rm -rf "/tmp/hugo"