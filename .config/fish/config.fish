switch (uname)
case Linux
    source $HOME/.config/fish/linux.fish
case Darwin
    source $HOME/.config/fish/darwin.fish
end

# env vars
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache

# direnv
if command -v direnv > /dev/null
    eval (direnv hook fish)
end

## anyenv
if test -d $HOME/.anyenv
    set -x PATH $HOME/.anyenv/bin $PATH
#    eval (anyenv init - fish | source)
    source (anyenv init - fish | psub)
end

## pipenv
set -x PIPENV_VENV_IN_PROJECT true

## go
set -x GOPATH ~/go
set -x PATH $HOME/go/bin $PATH

# rust
set -x PATH $HOME/.cargo/bin $PATH

## gcloud sdk
set -x CLOUDSDK_PYTHON $HOME/.anyenv/envs/pyenv/shims/python
set -x CLOUDSDK_PYTHON_SITEPACKAGES 1

## locale
set -x LC_CTYPE en_US.UTF-8

## kubernetes
set -x KUBE_EDITOR nvim

## kubebuilder
set -x PATH /usr/local/kubebuilder/bin $PATH

## krew
set -gx PATH $PATH $HOME/.krew/bin

## asdf
source /usr/local/opt/asdf/libexec/asdf.fish

## alias
### alias common
#alias ls 'ls -a -G'
alias .. 'cd ..'
alias md 'mkdir'

### alias bottom
if command -v btm > /dev/null
    alias top="btm --color gruvbox --tree"
end

### alias exa
if command -v exa > /dev/null
    alias l="exa --icons"
    alias ls="exa --git --icons"
    alias la="exa --git -a --icons"
    alias ll="exa -lab --git --icons"
    alias tree="exa --tree --icons"
else
    alias l="ls"
    alias la="ls -a"
    alias ll="ls -al"
end

### alias bat
if command -v bat > /dev/null
    alias cat="bat --plain"
end

### alias procs
if command -v procs > /dev/null
    alias ps="procs"
    alias pst="procs --tree"
end

### alias git
alias g 'git'
alias ghb 'gh repo view -w'

### alias nvim
alias vi 'nvim'

### alias docker
alias d 'docker'
alias dc 'docker-compose'

### alias kubernetes
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

## kubectl plugin-manager krew
set -gx PATH $PATH $HOME/.krew/bin

### alias others
alias p 'peco'
alias l 'less'
alias df 'duf'

#key-bindings
function fish_user_key_bindings
    #peco
    bind \cr peco_select_history
end

# fish plugin
set -U GHQ_SELECTOR peco

## fish bobthefish-theme config
set -g theme_date_format "+20%y/%m/%d %H:%M"
set -g theme_display_k8s_context no

## The next line updates PATH for the Google Cloud SDK.
if [ -f '~/google-cloud-sdk/path.fish.inc' ]; . '~/google-cloud-sdk/path.fish.inc'; end
