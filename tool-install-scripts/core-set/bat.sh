if command -v batcat &> /dev/null; then
    echo "bat is already installed."
    exit 0
fi

if command -v bat &> /dev/null; then
    echo "bat is already installed."
    exit 0
fi

# you could use sudo but some of my computers don't allow it
# sudo apt install -y bat

curl -L -o /tmp/batcat.tar.gz https://github.com/sharkdp/bat/releases/download/v0.26.1/bat-v0.26.1-x86_64-unknown-linux-gnu.tar.gz && \
  tar -xzf /tmp/batcat.tar.gz -C /tmp && rm /tmp/batcat.tar.gz

cp -r "/tmp/bat-v0.26.1-x86_64-unknown-linux-gnu/bat" "$HOME/.local/bin" 
sudo mkdir -p /usr/local/share/man/man1
sudo cp -r "/tmp/bat-v0.26.1-x86_64-unknown-linux-gnu/bat.1" "/usr/local/share/man/man1/bat.1"
rm -rf "/tmp/bat-v0.26.1-x86_64-unknown-linux-gnu"

