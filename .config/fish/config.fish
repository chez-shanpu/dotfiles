# env vars
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache

# direnv
# eval (direnv hook fish)

# Path
set -x PATH $HOME/.ngrok $PATH
set -x PATH /home/linuxbrew/.linuxbrew/bin $PATH
set -x PATH ~/.local/bin $PATH
##PythonPath
set -x PYTHONPATH ./

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

# rust
set -x PATH $HOME/.cargo/bin $PATH

# kubernetes
set -x KUBE_EDITOR nvim
## kubebuilder
set -x PATH /usr/local/kubebuilder/bin $PATH
## krew
set -gx PATH $PATH $HOME/.krew/bin

# alias
## alias common
alias ls 'ls -a --color=auto'
alias .. 'cd ..'
alias md 'mkdir'
alias rm 'trash-put'

### alias exa
if command -v exa > /dev/null
    alias l="exa"
    alias ls="exa --git"
    alias la="exa --git -a"
    alias ll="exa -lab --git"
    alias tree="exa --tree"
else
    alias l="ls"
    alias la="ls -a"
    alias ll="ls -al"
end

## alias apt
alias aud 'sudo apt update'
alias aug 'sudo apt upgrade'
alias ain 'sudo apt install'
alias ase 'apt search'
alias als 'apt list'
alias alu 'apt list --upgradable'

## alias git
alias g 'git'
alias ghb 'gh repo view -w'

## alias nvim
alias vi 'nvim'

## alias docker
alias d 'docker'
alias dc 'docker-compose'

## alias kubernetes
alias k 'kubectl'
alias ka 'kubectl apply'
alias ke 'kubectl explain'
alias kg 'kubectl get'
alias kd 'kubectl describe'
alias kn 'kubens'
alias kc 'kubectx'
alias kcon 'kubectl get pods --all-namespaces -o=jsonpath=\'{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}\' | sort'
alias kcomdel 'kubectl get po | sed "1d" | grep -e Completed | cut -f 1 -d " " | xargs -I{} kubectl delete pod {}'
alias kerrdel 'kubectl get po | sed "1d" | grep -e Error | cut -f 1 -d " " | xargs -I{} kubectl delete pod {}'
### alias kubernetes thema
alias kcy 'set -g theme_display_k8s_context yes'
alias kcn 'set -g theme_display_k8s_context no'

## alias python
alias pip 'pip3'

## alias others
alias p 'peco'
alias l 'less'

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/shanpu/google-cloud-sdk/path.fish.inc' ]; . '/home/shanpu/google-cloud-sdk/path.fish.inc'; end
