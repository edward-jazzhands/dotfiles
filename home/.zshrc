# Location and size of the history file
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# History flags:
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries when adding a new one
setopt HIST_REDUCE_BLANKS     # Clean up extra spaces before saving commands
setopt HIST_IGNORE_SPACE      # Don't save lines starting with a space
# setopt SHARE_HISTORY          # Share command history across all open terminal windows
setopt INC_APPEND_HISTORY     # Save commands immediately to the file, not when exiting

# Navigation quality-of-life tweaks
setopt AUTO_CD                # Type a directory path without 'cd' to switch to it
setopt AUTO_PUSHD             # Automatically push visited directories onto a stack
setopt PUSHD_IGNORE_DUPS      # Don't push duplicate directories to the stack
setopt PUSHD_SILENT           # Hide the directory stack list on push/pop

# General behavior
setopt PROMPT_SUBST           # Allow prompt variables to be substituted
unsetopt BEEP                 # Mute system beep sound on errors


# Initialize the advanced Zsh completion engine (compinit)
autoload -Uz compinit
# Cache completions for faster shell startup
zstyle ':completion:*' rehash true
compinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive tab completion
zstyle ':completion:*' menu select                          # Arrow key menu to pick completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colorize completions using LS_COLORS

# Theme
ZSH_THEME="$HOME/.shell/themes/agnoster.zsh-theme"
if [[ -f "$ZSH_THEME" ]]; then
    source "$ZSH_THEME"
else
    echo "❌ Theme not found: $ZSH_THEME"
fi

dotfiles_list=(
    ".shell/exports"
    ".shell/functions"
    ".shell/aliases"
    ".shell/tools"
)

for dotfile in $dotfiles_list; do
    if [[ -f "$HOME/$dotfile" ]]; then
        source "$HOME/$dotfile" && echo "✅ sourced $HOME/$dotfile"
    else
        echo "❌ File not found: $HOME/$dotfile"
    fi
done