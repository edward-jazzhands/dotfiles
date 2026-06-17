# To export extensions list:
# code-server --list-extensions > extensions.txt

# Get the directory of this script. As long as this script stays
# in the dotfiles repo, this guarantees its running from the repo.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

xargs -r -L 1 code-server --install-extension < "$SCRIPT_DIR/openvsx-extensions.txt"
