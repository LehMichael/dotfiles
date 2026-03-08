if not set -q XDG_CONFIG_HOME
    set --export XDG_CONFIG_HOME "$HOME/.config"
end

set --global fish_greeting
set --global EDITOR nvim
set --global MANPAGER "nvim +Man!"
alias ls='eza --icons'

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
fish_add_path ~/.local/bin

set --global hydro_multiline true
# Vibrant blue for path (~/.dotfiles)
set --global hydro_color_pwd blue

# Soft gray for git branch name (with pink asterisk handled by Hydro itself)
set --global hydro_color_git brblack

# Light pink ❯ prompt
set --global hydro_color_prompt magenta

# Optional: softer pink duration (if you care about matching everything)
set --global hydro_color_duration magenta

# Red for errors (unchanged)
set --global hydro_color_error red

function last_history_item; echo $history[1]; end
abbr -a !! --position anywhere --function last_history_item
