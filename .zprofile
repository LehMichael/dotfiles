
if test -f /opt/homebrew/bin/brew; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export HOMEBREW_BUNDLE_FILE=~/.config/homebrew/Brewfile
fi

if test -d ~/src/pico-sdk; then
    export PICO_SDK_PATH=~/src/pico-sdk
fi

if [ -x "$(command -v go)" ]; then
    export PATH=$PATH:$(go env GOPATH)/bin
fi

if [ -x "$(command -v bob)" ]; then
    export PATH=~/.local/share/bob/nvim-bin:$PATH
fi

export PATH=~/bin:$PATH
