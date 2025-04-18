setopt interactive_comments

if test -d ~/.zsh/pure; then
    fpath+=($HOME/.zsh/pure)
else
    printf "pure not found pull with >> git submodule update --init\n"
fi

if test -d ~/.zsh/zsh-autocomplete; then
    source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
else
    printf "fzf-tab not found pull with >> git submodule update --init\n"
fi

if test -d ~/.zsh/zsh-autosuggestions; then
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
else
    printf "zsh-autosuggestions not found pull with >> git submodule update --init\n"
fi

if [ -x "$(command -v bob)" ]; then
    source <(bob complete zsh)
fi


# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# https://github.com/marlonrichert/zsh-autocomplete
bindkey -M menuselect  '^[[D' .backward-char  '^[OD' .backward-char
bindkey -M menuselect  '^[[C'  .forward-char  '^[OC'  .forward-char

bindkey              '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select
bindkey -M menuselect              '^I'         menu-complete
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete
zstyle ':completion:*' completer _complete _complete:-fuzzy _correct _approximate _ignored
# all Tab widgets
zstyle ':autocomplete:*complete*:*' insert-unambiguous yes

# all history widgets
zstyle ':autocomplete:*history*:*' insert-unambiguous yes

# ^S
zstyle ':autocomplete:menu-search:*' insert-unambiguous yes

autoload -U promptinit; promptinit
prompt pure
source <(fzf --zsh)
KEYTIMEOUT=1

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=1000
setopt SHARE_HISTORY

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias ls="ls --color=auto -Ga"
