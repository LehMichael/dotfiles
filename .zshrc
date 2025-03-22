setopt interactive_comments

if test -d ~/.zsh/pure; then
    fpath+=($HOME/.zsh/pure)
else
    printf "pure not found pull with >> git submodule update --init\n"
fi

autoload -U compinit; compinit
if test -d ~/.zsh/fzf-tab; then
    source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh
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
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

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
