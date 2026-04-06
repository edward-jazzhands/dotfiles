if command -v systemctl-tui &> /dev/null; then
    echo "systemctl-tui is already installed."
    exit 0
fi

curl https://raw.githubusercontent.com/rgwood/systemctl-tui/master/install.sh | bash