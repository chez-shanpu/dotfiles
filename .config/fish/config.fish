# env vars
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache

# Path
set -x PATH $HOME/.ngrok $PATH
set -x PATH /home/linuxbrew/.linuxbrew/bin $PATH

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
alias md 'mkdir'

## alias apt
alias aud 'sudo apt update'
alias aug 'sudo apt upgrade'
alias ain 'sudo apt install'
alias ase 'apt search'
alias als 'apt list'
alias alu 'apt list --upgradable'

## alias nvim
alias vi 'nvim'
alias vim 'nvim'

## alias docker
alias d 'docker'
alias dc 'docker-compose'

## alias kubernetes
alias k 'kubectl'
alias ky 'set -g theme_display_k8s_context yes'
alias kn 'set -g theme_display_k8s_context no'

#key-bindings
function fish_user_key_bindings
    #peco
    bind \cr peco_select_history
end

# fish plugin
set -U GHQ_SELECTOR peco

# fish bobthefish-theme config
set -g theme_date_format "+20%y/%m/%d %H:%M"
set -g theme_display_k8s_context no
