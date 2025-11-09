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

##### History Configuration #####
# 增加歷史記錄大小
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# 歷史記錄選項
setopt EXTENDED_HISTORY          # 記錄時間戳
setopt HIST_EXPIRE_DUPS_FIRST   # 刪除重複的舊條目
setopt HIST_IGNORE_DUPS         # 不記錄重複的命令
setopt HIST_IGNORE_SPACE        # 忽略以空格開頭的命令
setopt HIST_VERIFY              # 在執行歷史命令前先顯示
setopt SHARE_HISTORY            # 在多個終端間共享歷史

# 啟用菜單選擇模式（用於補全選擇）
zstyle ':completion:*' menu select
zmodload zsh/complist

##### History List with Built-in Completion #####
# 啟用歷史搜索功能
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# 上下箭頭用於歷史搜索（前綴匹配）
bindkey '^[[A' up-line-or-beginning-search    # 上箭頭
bindkey '^[[B' down-line-or-beginning-search  # 下箭頭

# 配置補全系統
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list ''  # 只做前綴匹配
zstyle ':completion:*:history-words' menu yes
zstyle ':completion:*:history-words' list yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' stop yes

# 創建自定義歷史選擇 widget
_select_history() {
  local selected
  # 獲取去重後的歷史列表（最近50條，反向排列）
  selected=$(fc -l 1 | awk '{$1=""; print substr($0,2)}' | awk '!seen[$0]++' | tail -50 | tail -r | fzf --height=40% --reverse --query="$LBUFFER")
  
  if [[ -n "$selected" ]]; then
    LBUFFER="$selected"
  fi
}

# 檢查是否有 fzf，如果沒有則使用內建的 history-incremental-search
if command -v fzf &> /dev/null; then
  zle -N _select_history
  bindkey '^R' _select_history
else
  # 使用 zsh 內建的歷史增量搜索
  bindkey '^R' history-incremental-search-backward
fi

# 在菜單選擇模式中的按鍵綁定
bindkey -M menuselect '^M' .accept-line           # Enter 接受
bindkey -M menuselect '^[[A' up-line-or-history   # 上箭頭
bindkey -M menuselect '^[[B' down-line-or-history # 下箭頭
bindkey -M menuselect '^[[Z' reverse-menu-complete # Shift+Tab