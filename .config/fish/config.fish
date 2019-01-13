# env vars
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache

# Path
set -x PATH $HOME/.ngrok $PATH

# anyenv
if test -d $HOME/.anyenv
    set -x PATH $HOME/.anyenv/bin $PATH
    eval (anyenv init - | source)
end

# pipenv
set -x PIPENV_VENV_IN_PROJECT true

# go
set -x GOPATH ~/go
set -x PATH $HOME/go/bin $PATH

# alias
alias ls 'ls -a --color=auto'
alias .. 'cd ..'

## alias apt
alias aud 'sudo apt update'
alias ain 'sudo apt install'
alias ase 'apt search'
alias als 'apt list'

## alias nvim
alias vi 'nvim'
alias vim 'nvim'


#key-bindings
function fish_user_key_bindings
    #peco
    bind \cr peco_select_history
end

# decors/fish-ghq ctrl+gが何故か反応しない
# set -U GHQ_SELECTOR peco
# 代わり
alias g 'ghq look (ghq list | peco)'