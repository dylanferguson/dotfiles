#!/bin/bash

# - environment -------------------
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH:$HOME/.local/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
eval "$(/opt/homebrew/bin/brew shellenv)"
export JAVA_HOME="/opt/homebrew/opt/openjdk"
export PATH="$JAVA_HOME/bin:$PATH"
export GOPATH="$HOME/.local/share/go"
export PATH="$GOPATH/bin:$PATH"
eval "$(fzf --bash)"

. "$HOME/.bashrc"

[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"

bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export FZF_DEFAULT_COMMAND='rg --files --hidden --ignore .git --ignore node_modules'

# - navigation -------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cl='clear'
alias ls='eza'
alias b='bat'
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"

# - git -------------------
#Everything else lives in .gitconfig as a git alias
alias g='git'
alias current-branch='git rev-parse --abbrev-ref HEAD'
alias reset-to-remote='git fetch origin && git reset --hard origin/$(current-branch)'

# - agents -------------------
alias cc='claude'
alias cc-yolo='claude --dangerously-skip-permissions'
alias oc='opencode'
alias agents-here='ln -sf ~/.dotfiles/AGENTS.md ./AGENTS.md && echo "Linked AGENTS.md → $(pwd)/AGENTS.md"'

# - this machine -------------------
alias bash-reset='. ~/.bash_profile'
alias brewup='brew update; brew upgrade; brew cleanup; brew cleanup --prune-prefix; brew doctor'
alias update-all-the-things='$HOME/.dotfiles/update.sh'
alias myip='curl ifconfig.co'
alias flushDNS='dscacheutil -flushcache'

proc_on_port() { lsof -i :"$1"; }

# - tmux / zellij -------------------
alias tls='tmux ls'
alias ta='tmux attach -t'

tm() {
  tmux attach -t "$1" 2>/dev/null || tmux new -s "$1"
}

alias zls='zellij list-sessions'

zj() {
  zellij attach "$1" 2>/dev/null || zellij --session "$1"
}

# - docker -------------------
docker_it() {
  docker run -it --entrypoint /bin/bash "$1"
}

# - media -------------------
get_codec() {
  ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$1"
}

#extract: unpack most known archives with one command
extract() {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unar "$1"        ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# - meat -------------------
#Route through the OpenCode Zen gateway (no OpenAI/Anthropic key of our own).
#Scoped to this call so ANTHROPIC_API_KEY never leaks into other tools.
meat() {
  local key
  key=$(jq -r '.opencode.key // empty' "$HOME/.local/share/opencode/auth.json" 2>/dev/null)
  if [ -z "$key" ]; then
    echo "meat: no OpenCode Zen credential; run 'opencode auth login'" >&2
    return 1
  fi
  OPENAI_BASE_URL="https://opencode.ai/zen/v1" \
  OPENAI_API_KEY="$key" \
  MEAT_MODEL="${MEAT_MODEL:-gpt-5.6-sol}" \
  command meat "$@"
}

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
