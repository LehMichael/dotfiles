
if [ -x "$(command -v scutil)" ] && [[ $(scutil --get LocalHostName) = "Michaels-MacBook-Pro" ]]; then
    fpath+=("$(brew --prefix)/share/zsh/site-functions")

    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source $(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
else
    fpath+=($HOME/.zsh/pure)

    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi

if [ -x "$(command -v bob)" ]; then
    source <(bob complete zsh)
fi

bindkey -M menuselect '\r' .accept-line
bindkey -M menuselect  '^[[D' .backward-char  '^[OD' .backward-char
bindkey -M menuselect  '^[[C'  .forward-char  '^[OC'  .forward-char
bindkey              '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select
bindkey -M menuselect              '^I'         menu-complete
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete
# autoload -Uz compinit
# compinit
autoload -U promptinit; promptinit
prompt pure
setopt inc_append_history
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
KEYTIMEOUT=1

# if [ -z "$TMUX" ]
# then
# /opt/homebrew/bin/tmux new -As0
# fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

