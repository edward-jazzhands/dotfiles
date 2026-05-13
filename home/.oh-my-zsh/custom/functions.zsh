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

rename-files() {
  local old_prefix="$1"
  local new_prefix="$2"

  if [[ -z "$old_prefix" || -z "$new_prefix" ]]; then
    echo "Usage: rename_files <old_prefix> <new_prefix>"
    return 1
  fi

  local count=0
  for f in "${old_prefix}"*; do
    [[ -e "$f" ]] || { echo "No files found matching '${old_prefix}*'"; return 1; }
    local new_name="${f/${old_prefix}/${new_prefix}}"
    mv "$f" "$new_name" && ((count++))
    echo "Renamed $f to $new_name"
  done

  echo "Renamed $count file(s)."
}

# ┌───────────────────────┐
# │    FZF and Ripgrep    │
# └───────────────────────┘

# fuzzy shell history
fsh() {
  # eval "$(history | fzf | sed 's/ *[0-9]* *//')"
  fn=$(history | fzf | sed 's/ *[0-9]* *//')
  print -s "$fn"
  eval "$fn"
}

# search by file name
rgf() {
  rg --files --iglob "*$1*"
}

# search by function name and run the selected function (excludes any with leading underscore)
funcs() {
  if ! command -v fzf &>/dev/null; then
    echo "fns: fzf is required but not installed"
    return 1
  fi

  local tmp fn
  
  # mktemp creates a temporary file with a unique name in /tmp and returns its path.
  tmp=$(mktemp)

  # trap ensures that the temp file is deleted when the script exits,
  # including if the user presses Ctrl-C halfway through.
  trap "rm -f '$tmp'" EXIT

  # This dumps the source code of every currently defined shell function 
  # into the temp file.
  functions > $tmp

  local preview_cmd
  if command -v batcat &>/dev/null; then

    # This is the main pipeline. Breaking it down:
    #
    #   print -l ${(ok)functions:#_*}
    #            │  │            │
    #            │  │            └── :#_*  → filter out keys matching the pattern _*
    #            │  │            (removes all underscore-prefixed internal functions)
    #            │  └── (ok) → 'o' sorts the keys alphabetically, 'k' extracts just the keys
    #            │       (keys of the $functions associative array = function names only)
    #            └── $functions → built-in zsh associative array mapping function names to bodies
    #
    #   --preview "awk '...' $tmp"
    #     │
    #     └── preview arg: for each item highlighted in fzf, run this command.
    #         The command runs awk against our temp file to extract and display 
    #         just that function's source code in the preview pane.
    #
    #   The awk program:  /^{} \(\)/{found=1} found{print; if(/^\}/) exit}
    #       │
    #       │   {} is special fzf syntax to replace the currently highlighted function name,
    #       │   so if you highlight 'myfunction', awk sees: /^myfunction \(\)/{found=1}
    #       │
    #       ├── /^{} \(\)/{found=1}
    #       │   └── Pattern: match a line that starts with the function name followed by ' ()'
    #       │       When matched, set a flag variable 'found' to 1 (truthy)
    #       │
    #       └── found{print; if(/^\}/) exit}
    #           └── While 'found' is truthy, print every line we encounter.
    #               After printing each line, check if it matches /^\}/ — a closing brace
    #               at the start of the line, which is how 'functions' terminates each definition.
    #               If we see it, call exit to stop processing — we've printed the full function.
    #
    #    --plain strips batcat's line numbers and file header so you just get the highlighted code
    #    --color=always forces color output since bat detects it's in a pipe and would otherwise disable it.
    #    --paging=never prevents batcat from using a pager, which could cause issues with fzf
    #    -l zsh makes batcat use the zsh syntax highlighter

    preview_cmd="awk '/^{} \(\)/{found=1} found{print; if(/^\}/) exit}' $tmp | batcat -l zsh --color=always --plain --paging=never"
  else

    # if no batcat, it'll just preview without any color or syntax highlighting
    preview_cmd="awk '/^{} \(\)/{found=1} found{print; if(/^\}/) exit}' $tmp"
  fi

  # Capture the output of fzf and assign it to the variable 'fn'.
  fn=$(print -l ${(ok)functions:#_*} | fzf --preview "$preview_cmd")

  # If the user pressed Escape or Ctrl-C, fzf returns an empty string.
  # [[ -n $fn ]] checks that $fn is non-empty before trying to run it.
  [[ -n $fn ]] && $fn
}

# ┌───────────────────┐
# │       Ranger      │
# └───────────────────┘

function ranger-cd {
    # local IFS=$'\t\n' sets the internal field separator to tabs and newlines, 
    # which prevents word splitting issues if your directory path has spaces.
    local IFS=$'\t\n'

    # local tempfile="$(mktemp -t tmp.XXXXXX)" creates a temporary file with a random name.
    # This is the file Ranger will write the last visited directory into.
    local tempfile="$(mktemp -t tmp.XXXXXX)"

    # --choosedir="$tempfile" tells Ranger to write the current directory to
    # that temp file on exit.
    # "${@:-$(pwd)}" passes any arguments you gave to the function,
    # and falls back to the current directory if you didn't pass any.
    ranger --choosedir="$tempfile" "${@:-$(pwd)}"

    # The if block checks that the tempfile exists, and that the directory written to it 
    # is different from your current one, then cds into it.
    if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
        cd -- "$(cat "$tempfile")" || return
    fi

    rm -f -- "$tempfile"
}


# ┌───────────────────────┐
# │          Git          │
# └───────────────────────┘

git-upstream() {
  git remote set-url origin "$1"
}

git-hardsync() {
	git fetch upstream
	git checkout main
	git reset --hard upstream/main
}

git-prune-branches() {
  # Capture pruned remote branches
  pruned_branches=$(git fetch -p 2>&1 | grep '\[deleted\]' | sed -E 's/.*-> origin\///')

  if [[ -z "$pruned_branches" ]]; then
      echo "No pruned branches. Nothing to do."
      exit 0
  fi

  echo "Remote branches pruned:"
  echo "$pruned_branches"
  echo

  # Loop through each pruned branch
  for pruned in $pruned_branches; do
      if git show-ref --verify --quiet "refs/heads/$pruned"; then
          read -p "Local branch '$pruned' matches a just-pruned remote. Delete? [y/N] " confirm
          if [[ $confirm == [yY] ]]; then
              git branch -D "$pruned"
          fi
      fi
  done
}

# ┌───────────────────────┐
# │       Oh My Zsh       │
# └───────────────────────┘

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


# ┌───────────────────────┐
# │       Hardware        │
# └───────────────────────┘

fix-audio() {
    local services=("pipewire" "wireplumber" "pipewire-pulse")

    for service in "${services[@]}"; do
        if ! systemctl --user cat "$service" &>/dev/null; then
            echo "Error: $service is not present on this system" >&2
            return 1
        fi
    done

    systemctl --user restart pipewire pipewire-pulse wireplumber
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        echo "Error: failed to restart audio services" >&2
        return $exit_code
    fi

    echo "Audio services restarted successfully"
}


# More flexible version
add-latency() {
    local iface=${1:-"unset"}
    local delay=${2:-100ms}

    if [[ "$iface" == "unset" ]]; then
        echo "Usage: add-latency <interface> <delay>"
        echo "Example: add-latency eth0 100ms"
        echo "Use show-interfaces to see available interfaces"
        return 1
    fi

    sudo tc qdisc add dev "$iface" root netem delay "$delay"
    echo "Added ${delay} latency to ${iface}"
}

remove-latency() {
    local iface=${1:-"unset"}

    if [[ "$iface" == "unset" ]]; then
        echo "Usage: remove-latency <interface>"
        echo "Use show-interfaces to see available interfaces"
        return 1
    fi
    sudo tc qdisc del dev "$iface" root 2>/dev/null && echo "Removed latency from ${iface}" || echo "No latency rules found on ${iface}"
}



# ┌──────────────────────┐
# │        Ollama        │
# └──────────────────────┘

howto() {
  if [[ -z "$1" ]]; then
    echo "Usage: howto <command description>" >&2
    return 1
  fi

  local prompt="What is the bash/linux command to: $1
Return a single runnable command only. No markdown, no backticks, no explanation, no $ prefix."
  local cmd cmd_cleaned

  cmd=$(llm "$prompt")

  if [[ -z "$cmd" ]]; then
    echo "No command returned." >&2
    return 1
  fi

  # Strip markdown fences, backticks, and leading "$ "
  cmd_cleaned=$(echo "$cmd" \
    | sed '/^```/d' \
    | sed 's/`//g' \
    | sed 's/^[[:space:]]*\$[[:space:]]*//' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  echo ""
  echo "  $cmd_cleaned"
  echo ""
  read -r "REPLY?Run this? [y/N] "
  echo ""

  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    print -s "$cmd_cleaned"
    eval "$cmd_cleaned"
  else
    echo "Cancelled."
  fi
}

# ┌──────────────────────┐
# │        Docker        │
# └──────────────────────┘


docker-id() {
  if [[ -z "$1" ]]; then
    echo "Usage: docker-id <container-name>"
    return 1
  fi

  sudo docker run --rm --entrypoint '' $1 id
  echo ""
}

docker-logs() {
  if [[ -z "$1" ]]; then
    echo "Usage: docker-logs <container-name>"
    return 1
  fi

  sudo docker logs --follow --tail=100 "$1"
  echo ""
}
