set -x PATH $HOME/.anyenv/bin $PATH
eval (anyenv init - | source)

set -x PIPENV_VENV_IN_PROJECT true

set -x GOPATH ~/go
set -x PATH $HOME/go/bin $PATH

# alias
alias ls 'ls -a --color=auto'
alias .. 'cd ..'

## alias apt
alias aptupd 'apt update'
alias aptin 'apt install'
alias aptsa 'apt search'
alias aptls 'apt list'

## alias git+peco
alias g 'cd (ghq root)/(ghq list | peco)'

#peco
function fish_user_key_bindings
    bind \cr peco_select_history
end