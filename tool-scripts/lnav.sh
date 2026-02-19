# lnav (Logfile Navigator)
curl -L -o /tmp/lnav.zip https://github.com/tstack/lnav/releases/download/v0.13.2/lnav-0.13.2-linux-musl-x86_64.zip && \
  unzip /tmp/lnav.zip -d /tmp && rm /tmp/lnav.zip  

cp -r "/tmp/lnav-0.13.2/lnav" "$HOME/.local/bin" 
sudo mkdir -p /usr/local/share/man/man1
sudo cp -r "/tmp/lnav-0.13.2/lnav.1" "/usr/local/share/man/man1/lnav.1"
rm -rf "/tmp/lnav-0.13.2"

