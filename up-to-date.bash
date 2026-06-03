#!/usr/bin/env bash

# Run this from your .profile to be notified when your dotfiles are
# behind origin.

# Add the following lines to your ~/.profile:
#```
#    export DOTFILES_DIR="$HOME/dotfiles"

#    # Run in the background cause it might take a couple seconds depending
#    # on how Github feels today:
#    ( bash "$DOTFILES_DIR/dotfiles-up-to-date.bash" ) 2>/dev/null &
#    disown
#```

# Get the directory of this script. As long as this script stays
# in the dotfiles repo, this guarantees its running from the repo.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Text formatting (gracefully degrades if terminal doesn't support it)
bold=""
yellow=""
red=""
reset=""
if [ -t 1 ] && command -v tput &>/dev/null; then
    bold="$(tput bold 2>/dev/null || true)"
    yellow="$(tput setaf 3 2>/dev/null || true)"
    red="$(tput setaf 1 2>/dev/null || true)"
    reset="$(tput sgr0 2>/dev/null || true)"
fi


if [ ! -d "$SCRIPT_DIR/.git" ]; then
    printf "Could not find .git directory in $SCRIPT_DIR\n"
    exit 1
fi

# Determine the tracking branch (handles non-main default branches)
remote="$(git -C "$SCRIPT_DIR" remote 2>/dev/null | head -n1)"
if [ -z "$remote" ]; then
    printf "fetch-failed: Could not determine remote for $SCRIPT_DIR\n"
    exit 1
fi

branch="$(git -C "$SCRIPT_DIR" symbolic-ref --short HEAD 2>/dev/null)"
if [ -z "$branch" ]; then
    printf "fetch-failed: Could not determine branch for $SCRIPT_DIR\n"
    exit 1
fi

tracking="${remote}/${branch}"

# Fetch quietly; bail out if no network / auth issue
if ! git -C "$SCRIPT_DIR" fetch "$remote" --quiet 2>/dev/null; then
    printf "fetch-failed: Could not fetch $remote for $SCRIPT_DIR\n"
    exit 1
fi

local_sha="$(git -C "$SCRIPT_DIR" rev-parse HEAD 2>/dev/null)"
remote_sha="$(git -C "$SCRIPT_DIR" rev-parse "$tracking" 2>/dev/null)"

if [ -z "$local_sha" ] || [ -z "$remote_sha" ]; then
    printf "fetch-failed: Could not determine SHA for $SCRIPT_DIR\n"
    exit 1
fi

if [ "$local_sha" = "$remote_sha" ]; then
    printf "dotfiles are up-to-date\n"
    exit 0
fi

merge_base="$(git -C "$SCRIPT_DIR" merge-base HEAD "$tracking" 2>/dev/null)"

if [ "$merge_base" = "$remote_sha" ]; then
    printf "%s%s◆ dotfiles%s: %s is ahead of origin (unpushed commits).\n" \
        "$bold" "$yellow" "$reset" "$SCRIPT_DIR"
elif [ "$merge_base" = "$local_sha" ]; then
    count="$(git -C "$SCRIPT_DIR" rev-list --count HEAD.."$tracking" 2>/dev/null)"
    printf "%s%s✘ dotfiles%s: %s behind origin by %s commit(s). Run: git -C %s pull\n" \
        "$bold" "$red" "$reset" "$SCRIPT_DIR" "$count" "$SCRIPT_DIR"
else
    printf "%s%s✘ dotfiles%s: %s has diverged from origin (commits on both sides).\n" \
        "$bold" "$red" "$reset" "$SCRIPT_DIR"
fi

