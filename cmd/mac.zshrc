export LANG=en_US.UTF-8

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

##### Docker & Kubernetes #####
autoload -Uz compinit
compinit
source <(kubectl completion zsh)

alias d=docker
alias k=kubecolor

alias kx=kubectx
alias kns=kubens
alias kgp="k get pod"

compdef _kubectl kubecolor k

##### Git #####
alias gpp="git pull"
alias gs="git status"

alias cc=clear