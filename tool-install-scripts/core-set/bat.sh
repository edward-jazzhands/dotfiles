if command -v batcat &> /dev/null; then
    echo "batcat is already installed."
    exit 0
fi

sudo apt install -y bat