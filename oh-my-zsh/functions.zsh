# Prints a color gradient to test truecolor support
colortest() {
  awk 'BEGIN{
      s=" "; s=s s s s s s s s;
      for (colnum = 0; colnum<77; colnum++) {
          r = 255-(colnum*255/76);
          g = (colnum*510/76);
          b = (colnum*255/76);
          if (g>255) g = 510 - g;
          printf "\033[48;2;%d;%d;%dm%s\033[0m", r,g,b,substr(s,colnum%8+1,1);
      }
      printf "\n";
  }'
}

# Show all apps manually installed by user (ONLY FOR LINUX MINT at the moment)
installed-apps() {
  gsettings get com.linuxmint.install installed-apps | tr ',' '\n' | tr -d "[]'" | sed 's/^ *//'
}

# Download entire website with wget
wgetsite() {
    if [ -z "$1" ]; then
        echo "Usage: wgetsite <url>"
        echo "Example: wgetsite https://example.com/docs/"
        return 1
    fi
    wget -r -np -k -p -E "$1"
    # -r = recursive
    # -np = no parent
    # -k = convert links to local files
    # -p = page requisites (download images, css, js, etc.)
    # -E = use .html extension
}

# ┌───────────────────────┐
# │    FZF and Ripgrep    │
# └───────────────────────┘

# fuzzy cd
fcd() {
  local dir
  dir=$(find . -type d -not -path '*/\.*' | fzf) && cd "$dir"
}

# fuzzy shell history
fsh() {
  eval "$(history | fzf | sed 's/ *[0-9]* *//')"
}

# search by file name
rgf() {
  rg --files --iglob "*$1*"
}


# Turn Oh My Zsh plugins on or off and reload
my-plugins() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: my-plugins on|off <plugin-name>"
    return 1
  fi
  if [[ "$1" == "on" ]]; then
    omz plugin enable "$2"
    exec zsh
  elif [[ "$1" == "off" ]]; then
    omz plugin disable "$2"
    exec zsh
  else
    echo "Invalid option: $1. Choose on or off."
    return 1
  fi
}