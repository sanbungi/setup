# 表示系
alias ll='ls -la --color=auto'
alias grep='grep --color=auto'

# 安全系
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# 省略系
alias ..='cd ../'
alias update='sudo apt update && sudo apt upgrade'
alias h='history'

# 開発系
# docker
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dps='docker ps -a'
alias dexec='docker exec -it'

# git
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log'
alias gitaddreset='git restore --staged .'

# nodejs
alias npdev='npm run dev'
alias npstart='npm run start'

# python
alias venv='. venv/bin/activate'
alias p='python'
