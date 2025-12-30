export LANG=en_US.UTF-8

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# git clone https://github.com/doggy8088/better-rm.git ~/better-rm
alias rm='~/better-rm/better-rm'

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

##### Port Check #####
# Check which process is using a specific port
port() {
  if [[ -z "$1" ]]; then
    echo "Usage: port <port_number>"
    return 1
  fi
  
  local port_result=$(lsof -i :$1 2>/dev/null)
  
  if [[ -n "$port_result" ]]; then
    # Show listening process first (the actual port owner)
    local listen_result=$(echo "$port_result" | grep -E "(COMMAND|LISTEN)")
    if [[ -n "$listen_result" ]]; then
      echo "=== Listening on port $1 ==="
      echo "$listen_result"
      echo ""
    fi
    
    # Show all connections
    echo "=== All connections on port $1 ==="
    echo "$port_result"
  else
    echo "Port $1 is not in use."
  fi
}

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
  # 獲取去重後的歷史列表（最近200條，反向排列）
  selected=$(fc -l 1 | awk '{$1=""; print substr($0,2)}' | awk '!seen[$0]++' | tail -200 | tail -r | fzf --height=40% --reverse --query="$LBUFFER")
  
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

##### Kubernetes Resource List #####
# 記憶體單位轉換函數：將 Gi/Mi/bytes 轉換為 MiB
convert_to_mib() {
  local memory=$1
  
  if [[ -z "$memory" || "$memory" == "null" ]]; then
    echo "0"
    return
  fi
  
  # 提取單位（最後兩個字符）
  local unit="${memory: -2}"
  
  case "$unit" in
    Gi)
      # Gi 轉 Mi：乘以 1024
      local value="${memory%Gi}"
      echo $(( ${value%.*} * 1024 ))
      ;;
    Mi)
      # Mi 直接返回
      local value="${memory%Mi}"
      echo "${value%.*}"
      ;;
    *m)
      # bytes (m 結尾) 轉 Mi
      local value="${memory%m}"
      echo $(( value / 1024 / 1024 ))
      ;;
    *)
      echo "0"
      ;;
  esac
}

# krl - Kubernetes Resource List
# 顯示 pod/container 的資源使用情況（CPU/Memory）與 requests/limits 的比較
krl() {
  # 檢查 jq 是否安裝
  if ! command -v jq >/dev/null 2>&1; then
    echo "錯誤: jq 未安裝。請執行: brew install jq"
    return 1
  fi
  
  # 檢查 kubectl 是否可用
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "錯誤: kubectl 未安裝"
    return 1
  fi
  
  # 使用關聯數組儲存 pod/container 資源配置
  typeset -A pod_containers
  
  # 獲取所有 pod 的資源配置
  local pods_json=$(kubectl get pods -o json 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "錯誤: 無法獲取 pods 資訊"
    return 1
  fi
  
  # 解析 pod 資源配置
  while IFS='|' read -r pod_name container_name req_mem limit_mem req_cpu limit_cpu; do
    if [[ -n "$pod_name" && -n "$container_name" ]]; then
      local req_mem_mib=$(convert_to_mib "$req_mem")
      local limit_mem_mib=$(convert_to_mib "$limit_mem")
      local key="${pod_name}::${container_name}"
      pod_containers[$key]="${req_mem_mib}|${limit_mem_mib}|${req_cpu}|${limit_cpu}"
    fi
  done < <(echo "$pods_json" | jq -r '.items[] | 
    .metadata.name as $pod | 
    .spec.containers[] | 
    "\($pod)|\(.name)|\(.resources.requests.memory // "0")|\(.resources.limits.memory // "0")|\(.resources.requests.cpu // "0")|\(.resources.limits.cpu // "0")"')
  
  # 獲取實際使用情況
  local top_output=$(kubectl top pod --containers --no-headers 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "錯誤: 無法獲取 pod 使用情況。請確保 metrics-server 已安裝"
    return 1
  fi
  
  # 準備輸出數據
  local output_data=""
  
  while read -r line; do
    if [[ -z "$line" ]]; then
      continue
    fi
    
    # 解析 kubectl top 輸出
    local fields=($=line)
    local pod_name="${fields[1]}"
    local container_name="${fields[2]}"
    local used_cpu="${fields[3]}"
    local used_mem="${fields[4]}"
    
    # 獲取該 container 的配置
    local key="${pod_name}::${container_name}"
    local config="${pod_containers[$key]}"
    
    if [[ -n "$config" ]]; then
      IFS='|' read -r req_mem limit_mem req_cpu limit_cpu <<< "$config"
      
      # 檢查記憶體是否超過 request
      local alert=""
      local used_mem_value="${used_mem%Mi}"
      if [[ "$used_mem_value" =~ ^[0-9]+$ ]] && [[ "$req_mem" =~ ^[0-9]+$ ]]; then
        if (( used_mem_value > req_mem )); then
          alert="*"
        fi
      fi
      
      # 格式化輸出行
      local pod_container="${pod_name} (${container_name})"
      local mem_info="${used_mem}/${req_mem}Mi/${limit_mem}Mi"
      local cpu_info="${used_cpu}/${req_cpu}/${limit_cpu}"
      
      output_data="${output_data}${pod_container}|${mem_info}|${cpu_info}|${alert}\n"
    fi
  done <<< "$top_output"
  
  # 使用 awk 格式化輸出表格
  echo -e "$output_data" | awk -F'|' '
    BEGIN {
      # 標題
      header[1] = "Pod_Container"
      header[2] = "Mem_Used_Req_Limit"
      header[3] = "Cpu_Used_Req_Limit"
      header[4] = "MemExceedRequest"
      
      # 初始化最大寬度
      max[1] = length(header[1])
      max[2] = length(header[2])
      max[3] = length(header[3])
      max[4] = length(header[4])
      
      row_count = 0
    }
    
    NF > 0 {
      row_count++
      for (i = 1; i <= NF; i++) {
        data[row_count, i] = $i
        if (length($i) > max[i]) {
          max[i] = length($i)
        }
      }
    }
    
    END {
      if (row_count == 0) {
        print "沒有找到任何 pod 資料"
        exit
      }
      
      # 輸出標題
      printf "%-*s  %-*s  %-*s  %-*s\n", 
        max[1], header[1], 
        max[2], header[2], 
        max[3], header[3], 
        max[4], header[4]
      
      # 輸出分隔線
      for (i = 1; i <= max[1]; i++) printf "-"
      printf "  "
      for (i = 1; i <= max[2]; i++) printf "-"
      printf "  "
      for (i = 1; i <= max[3]; i++) printf "-"
      printf "  "
      for (i = 1; i <= max[4]; i++) printf "-"
      printf "\n"
      
      # 輸出數據行
      for (r = 1; r <= row_count; r++) {
        printf "%-*s  %-*s  %-*s  %-*s\n", 
          max[1], data[r, 1], 
          max[2], data[r, 2], 
          max[3], data[r, 3], 
          max[4], data[r, 4]
      }
    }
  '
}