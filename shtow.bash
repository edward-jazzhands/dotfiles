#!/usr/bin/env bash

echo "Shtow - Its like Stow, but a bash script."
echo "WARNING: This will overwrite existing symlinks."
echo "Are you sure you want to continue? [y/N]"
read -r REPLY

if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Continuing..."
else
    echo "Cancelled."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
src="home"
dest="$HOME"

# Make sure the script runs from its own directory so 'find "$src"' always works
cd "$SCRIPT_DIR" || exit 1

# Sanity check
if [ ! -d "$src" ]; then
    echo "Error: Source directory '$SCRIPT_DIR/$src' not found."
    exit 1
fi

# find "$src" -type f  →  recursively lists all regular files under src,
# one per line. -type f excludes directories and symlinks.
find "$src" -type f -print0 | while IFS= read -r -d '' file; do

    # ${file#$src/}  →  strips the leading "home/" prefix using bash's
    # prefix-stripping parameter expansion. The # means "remove the shortest
    # match of this pattern from the front of the string".
    #   e.g. "home/.config/nvim/init.lua" → ".config/nvim/init.lua"
    #
    # We then prepend $dest/ to get the full target path:
    #   e.g. "/home/user/.config/nvim/init.lua"
    target="$dest/${file#$src/}"

    # dirname strips the filename component, leaving just the directory path.
    #   e.g. "/home/user/.config/nvim/init.lua" → "/home/user/.config/nvim"
    target_dir="$(dirname "$target")"

    mkdir -p "$target_dir"

    # if the target path exists and is not a symlink...
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "SKIP (real file exists): $target"
        continue
        # Note: We do not need to distinguish between files and directories
        # here because the find command already excluded directories.
    fi

    echo "Linking: $file -> $target"

    # -s means symlink (vs hard link).
    # -f means force: replace any existing symlink at the target without error.
    ln -sf "$SCRIPT_DIR/$file" "$target"
done