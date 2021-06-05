#!/bin/bash

export PATH="$PATH:$HOME/.local/bin"

. "$HOME/.bashrc"

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
[ -f "$(brew --prefix)/etc/profile.d/z.sh" ] && source "$(brew --prefix)/etc/profile.d/z.sh" # rupa's Z
[ -f "$(brew --prefix asdf)/asdf.sh" ] && source "$(brew --prefix asdf)/asdf.sh"

bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

eval "$(thefuck --alias)" 

export HOMEBREW_NO_ANALYTICS=1
export GATSBY_TELEMETRY_DISABLED=1
export HOMEBREW_NO_AUTO_UPDATE=1
export ANSIBLE_COW_SELECTION=random
export ANSIBLE_NOCOWS=1
export FZF_DEFAULT_COMMAND='ag -U --hidden --ignore .git --ignore node_modules -g ""'
export NVM_DIR="$HOME/.nvm"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias g='git'
alias git-repo='git rev-parse --is-inside-work-tree 2> /dev/null'
alias git-branch-sorted='git branch --sort=-committerdate'
alias get-remote='git ls-remote --get-url'
alias chrome-devtools='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --auto-open-devtools-for-tabs'
alias current-branch='git rev-parse --abbrev-ref HEAD'
alias origin-diff='git fetch && git diff origin'
alias reset-to-remote='git fetch origin && git reset --hard origin/$(current-branch)'
alias bash-reset='. ~/.bash_profile'
alias brewup='brew update; brew upgrade; brew cleanup; brew cleanup --prune-prefix; brew doctor'
alias cat='bat'
alias cl='clear'
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias grep='rg'
alias ls='exa'
alias pbjson='pbpaste | json_pp | pbcopy' # / jq '.'
alias ping='prettyping --nolegend'
alias pg='postgres'
alias python-venv-init='python3 -m venv .venv; source .venv/bin/activate; pip install -r requirements.txt'
alias top='sudo htop'
alias update-all-the-things='$HOME/.dotfiles/update.sh'
alias weather="curl -s 'https://wttr.in/elwood?q&n&p'"
alias zsh-reset='. ~/.zshrc'
alias tcp_ports='netstat -ant | grep LISTEN'


git_lazy_commit() {
  local msg branch
  if [ ! "$(git-repo)" ]; then
    echo "nope, not a git repo"
    return 1
  fi

  msg="update"
  if [ -n "$1" ]; then msg="$*"; fi

  branch=$(git rev-parse --abbrev-ref HEAD)
  read -p "Are you sure you want to push to $branch w/ the commit message '$msg'? (y/n): " -n 1 -r < /dev/tty
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    git add -p
    git commit -m "$msg"
    git push
  else
    echo -e "\nPush aborted."
  fi
}

# fuzzy git checkout
fbr() {
  local branches branch
  branches=$(git --no-pager branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout "$(echo "$branch" | awk '{print $1}' | sed "s/.* //")"
}

compress_file() {
  local name ext
  name=$(echo "$1" | cut -d'.' -f1)_out
  ext=$(echo "$1" | cut -d'.' -f2)

  if [[ -f "$1" ]]; then
    case "$1" in
      *.jpg)    convert "$1" -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace sRGB "${name}.jpg";;
      *.png)    convert "$1" -strip "${name}.png";;
      *.gif)    ffmpeg -i "$1" -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" "${name}.mp4";;
      *.mp4)    ffmpeg -an -i "$1" -vcodec h264 -crf 17 "${name}.mp4";;
      *)        echo "$ext is not supported";;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

proc_on_port() { lsof -i :"$1"; }

time_d() { /usr/bin/time -l "$@"; }

cmprss_diff() {
  local original gz brotli
  original=$(wc -c "$1" | awk '{print $1}')
  gz=$(gzip -c "$1" | wc -c | awk '{print $1}')
  brotli=$(brotli -c "$1" | wc -c | awk '{print $1}')
  echo "gzip:   $(bc <<< "scale=2; ($original - $gz) / $original * 100")% reduction"
  echo "brotli: $(bc <<< "scale=2; ($original - $brotli) / $original * 100")% reduction"
}

# - docker -------------------
alias docker_clear_containers='docker rm -f $(docker ps -a -q)'
docker_it() {
  docker run -it --entrypoint /bin/bash "$1"
}

# - aws -------------------
aws_deploy_lambda() {
    zip -r f.zip . && aws lambda update-function-code --region ap-southeast-2 --function-name "$1" --zip-file fileb://f.zip
}

get_codec () {
    ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$1"
}

record_screen() {
    ffmpeg -f avfoundation -i 1:0 "$(date +%s).mkv"
}

#extract:  Extract most know archives with one command
extract () {
        if [ -f "$1" ] ; then
          case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
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

#   memHogsTop, memHogsPs:  Find memory hogs
#   -----------------------------------------------------
alias memHogsTop='top -l 1 -o rsize | head -20'
alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'

#   cpuHogs:  Find CPU hogs
#   -----------------------------------------------------
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

#Networking 
alias editHosts='sudo edit /etc/hosts'
alias flushDNS='dscacheutil -flushcache'            # flushDNS:     Flush out the DNS Cache
alias ipInfo0='ipconfig getpacket en0'              # ipInfo0:      Get info on connections for en0
alias ipInfo1='ipconfig getpacket en1'              # ipInfo1:      Get info on connections for en1
alias lsock='sudo /usr/sbin/lsof -i -P'             # lsock:        Display open sockets
alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'   # lsockT:       Display only open TCP sockets
alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'   # lsockU:       Display only open UDP sockets
alias myip='curl ifconfig.co'                    # myip:         Public facing IP Address
alias netCons='lsof -i'                             # netCons:      Show all open TCP/IP sockets
alias openPorts='sudo lsof -i | grep LISTEN'        # openPorts:    All listening connections
alias showBlocked='sudo ipfw list'                  # showBlocked:  All ipfw rules inc/ blocked IPs


#   ii:  display useful host related informaton
#   -------------------------------------------------------------------
    ii() {
        echo -e "\nYou are logged on ${RED}$HOST"
        echo -e "\nAdditionnal information:$NC " ; uname -a
        echo -e "\n${RED}Users logged on:$NC " ; w -h
        echo -e "\n${RED}Current date :$NC " ; date
        echo -e "\n${RED}Machine stats :$NC " ; uptime
        echo -e "\n${RED}Current network location :$NC " ; scselect
        echo -e "\n${RED}Public facing IP Address :$NC " ;myip
        #echo -e "\n${RED}DNS Configuration:$NC " ; scutil --dns
        echo
    }

if command -v rbenv > /dev/null; then eval "$(rbenv init -)"; fi
