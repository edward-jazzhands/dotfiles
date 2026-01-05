# If not running interactively, don't do anything
# NOTE: This safety check basically prevents programs and scripts from sourcing this file
# since they shouldn't have any business sourcing it. It's a defensive check to prevent bugs
# and recommended for this to always be present.
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# NOTE: You may want to enable or disable this depending on if this is
# on a server environment (for example if you use a lot of tmux sessions,
# you may not want all sessions to combine into one history file)
# Append to the history file, don't overwrite it:
#shopt -s histappend

# NOTE: The defaults for this are 500/500
# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# NOTE: This is mostly defensive, if this wasn't here then there's not a lot
# of things affected. But doesn't hurt to have it.
# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

#! Ive never used chroot but this is here for reference
# Set variable identifying the chroot you work in (used in the prompt below)
#if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#    debian_chroot=$(cat /etc/debian_chroot)
#fi

# NOTE: This may be redundant but it's a defensive check, in case we're
# in some minimal environment that didn't set up the bash competions already.
# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# This sets the prompt to be color if we find color or 256 in TERM.
# NOTE: This block replaced a bunch of unnecessary checks in the default that provided
# compatibility with old hardware. I tend to use nice new terminals.
if [[ $TERM == *"color"* ]] || [[ $TERM == *"256"* ]]; then
    PS1="\$(date '+%H:%M:%S') \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
else
    PS1="\$(date '+%H:%M:%S') \u@\h:\w\$ "
fi

# NOTE: This updates the te>rminal tab title! It is important to have.
# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac


dotfiles_list=(
    ".init"
    ".exports"
    ".functions"
    ".aliases"
    ".tools"
)

for dotfile in "${dotfiles_list[@]}"; do
    source "$HOME/$dotfile" && echo "✅ sourced $HOME/.$dotfile"
done