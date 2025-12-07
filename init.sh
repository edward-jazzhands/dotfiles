# Create symlinks to the dotfiles in the home directory
# NOTE: cd to this folder before running this script

ln -s "$PWD/.bashrc" ~/.bashrc
ln -s "$PWD/.gitconfig" ~/.gitconfig
ln -s "$PWD/.gitignore_global" ~/.gitignore_global
ln -s "$PWD/.justfile" ~/.justfile
ln -s "$PWD/.tmux.conf" ~/.tmux.conf