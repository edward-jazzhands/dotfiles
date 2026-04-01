if command -v lazydocker &> /dev/null; then
    echo "Lazydocker is already installed."
    exit 0
fi

curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash