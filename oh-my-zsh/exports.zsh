# These are locality settings. They ensure the terminal uses American English
# style for formatting, dates, etc. C.UTF-8 (basic POSIX) is often recommended
# instead of en_US.UTF-8 for containerized environments. In a normal desktop
# environment these are usuallly set by the OS and not needed here.
# export LANG=en_US.UTF-8
# export LC_ALL=C.UTF-8

# Poertry by default creates virtual environments in its own internal location.
# This makes it place them in the project folder instead. This is essential in a
# container since only the project folder is bind mounted and persistent.
export POETRY_VIRTUALENVS_IN_PROJECT=true

# Set an env var for your personal github. 
# Allows you to `git clone $mygithub/repo-name` and other git commands.
export mygithub="https://github.com/edward-jazzhands"

# Add $HOME/.local/bin to the path
export PATH="$HOME/.local/bin:$PATH"

# Add $HOME/bin to the path
export PATH="$HOME/bin:$PATH"

if [ "$(hostname)" = "code-server" ]; then
    # code-server is a container so UV needs to copy python files
    # (instead of hard linking)
    export UV_LINK_MODE="copy"
fi