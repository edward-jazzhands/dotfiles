#!/usr/bin/env zsh
# zshrc-template-diff.plugin.zsh
# Checks if the Oh My Zsh .zshrc template has been updated and offers to show the diff
# Features:
#   Tracks the last seen commit hash of the template file
#   Checks if the template has changed since last check
#   Shows number of new lines added
#   Prompts user to view the diff
#   Auto-detects and uses delta or diff-so-fancy if available, falls back to plain git diff
#   Only checks once per day on shell startup (to avoid spam)
#   Provides an omz-template-diff alias for manual checking
# How it works:
#   Stores the last seen template commit hash in ~/.oh-my-zsh/cache/.zshrc-template-last-check
#   On shell startup (max once per day), compares current template version to last seen
#   If changed and has new additions, prompts the user
#   Updates the tracking file after showing diff

zshrc_template_diff_check() {
  local omz_dir="${ZSH:-$HOME/.oh-my-zsh}"
  local template_file="$omz_dir/templates/zshrc.zsh-template"
  local last_check_file="$omz_dir/cache/.zshrc-template-last-check"
  
  # Make sure we're in a git repo
  if [[ ! -d "$omz_dir/.git" ]]; then
    return 0
  fi
  
  # Get current commit hash of template
  local current_hash=$(cd "$omz_dir" && git log -1 --format="%H" -- templates/zshrc.zsh-template 2>/dev/null)
  
  if [[ -z "$current_hash" ]]; then
    return 0
  fi
  
  # Check if we've seen this version before
  if [[ -f "$last_check_file" ]]; then
    local last_hash=$(cat "$last_check_file")
    
    if [[ "$current_hash" == "$last_hash" ]]; then
      return 0
    fi
    
    # Template has changed! Get the stats
    local stats=$(cd "$omz_dir" && git diff --numstat "$last_hash" "$current_hash" -- templates/zshrc.zsh-template 2>/dev/null)
    local additions=$(echo "$stats" | awk '{print $1}')
    
    if [[ "$additions" -gt 0 ]]; then
      echo ""
      echo "📝 Oh My Zsh .zshrc template has been updated!"
      echo "   $additions new line(s) in the template since your last check."
      echo ""
      
      # Prompt user
      read "response?Would you like to view the changes? (y/n) "
      if [[ "$response" =~ ^[Yy]$ ]]; then
        # Try to use a nice diff tool, fall back to git diff
        if command -v delta &> /dev/null; then
          (cd "$omz_dir" && git diff "$last_hash" "$current_hash" -- templates/zshrc.zsh-template | delta)
        elif command -v diff-so-fancy &> /dev/null; then
          (cd "$omz_dir" && git diff "$last_hash" "$current_hash" -- templates/zshrc.zsh-template | diff-so-fancy | less -R)
        else
          (cd "$omz_dir" && git diff "$last_hash" "$current_hash" -- templates/zshrc.zsh-template | less)
        fi
        
        echo ""
        echo "💡 Tip: Compare with your ~/.zshrc to see if you want to adopt any changes."
      fi
    fi
  fi
  
  # Update the last check file
  mkdir -p "$(dirname "$last_check_file")"
  echo "$current_hash" > "$last_check_file"
}

# Hook into Oh My Zsh update process if using omz update
# Otherwise, check on shell startup (but not every time, use a daily check)
if [[ -n "$OMZ_ZSHRC_TEMPLATE_CHECK" ]] || [[ ! -f "$ZSH/cache/.zshrc-template-daily-check" ]] || 
   [[ $(find "$ZSH/cache/.zshrc-template-daily-check" -mtime +1 2>/dev/null) ]]; then
  zshrc_template_diff_check
  touch "$ZSH/cache/.zshrc-template-daily-check" 2>/dev/null
fi

# Allow manual checking
alias omz-template-diff='OMZ_ZSHRC_TEMPLATE_CHECK=1 zshrc_template_diff_check'