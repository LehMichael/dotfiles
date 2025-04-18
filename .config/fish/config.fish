if status is-interactive
    # Commands to run in interactive sessions can go here
end

if test -f /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
    set -x HOMEBREW_BUNDLE_FILE ~/.config/homebrew/Brewfile
end

if type -q go
    fish_add_path (go env GOPATH)/bin
end

if type -q fzf
    fzf --fish | source
end

fish_add_path ~/bin

set --global hydro_multiline true
# Vibrant blue for path (~/.dotfiles)
set -U hydro_color_pwd blue

# Soft gray for git branch name (with pink asterisk handled by Hydro itself)
set -U hydro_color_git brblack

# Light pink ❯ prompt
set -U hydro_color_prompt magenta

# Optional: softer pink duration (if you care about matching everything)
set -U hydro_color_duration magenta

# Red for errors (unchanged)
set -U hydro_color_error red

# Let start symbol inherit from prompt or leave unset
# set -U hydro_color_start ''

