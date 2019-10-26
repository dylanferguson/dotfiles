#!/bin/bash

. ~/.bashrc

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

eval "$(thefuck --alias)"

export HOMEBREW_NO_AUTO_UPDATE=1
export ANSIBLE_COW_SELECTION=random
export ANSIBLE_NOCOWS=1
export FZF_DEFAULT_COMMAND='ag -U --hidden --ignore .git -g ""'

alias ..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cl='clear'
alias brewup='brew update; brew upgrade; brew cleanup; brew cleanup --prune-prefix; brew doctor'
alias bash-reset='. ~/.bash_profile'
alias zsh-reset='. ~/.zshrc'
alias cat='bat'
alias ping='prettyping --nolegend'
alias top='sudo htop'
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias weather="curl -s 'https://wttr.in/elwood?q&n&p'"
alias python-venv-init='python3 -m venv venv; activate; pip install -r requirements.txt'

#git 
git_lazy_commit() {
    git add .
    git commit -a -m "$1"
    git push
}

# aws 
aws_deploy_lambda() {
    zip -r f.zip . && aws lambda update-function-code --region ap-southeast-2 --function-name "$1" --zip-file fileb://f.zip
}

get_codec () {
    ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 $1
}

#extract:  Extract most know archives with one command
extract () {
        if [ -f $1 ] ; then
          case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
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
alias myip='curl ifconfig.co'                    # myip:         Public facing IP Address
alias netCons='lsof -i'                             # netCons:      Show all open TCP/IP sockets
alias flushDNS='dscacheutil -flushcache'            # flushDNS:     Flush out the DNS Cache
alias lsock='sudo /usr/sbin/lsof -i -P'             # lsock:        Display open sockets
alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'   # lsockU:       Display only open UDP sockets
alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'   # lsockT:       Display only open TCP sockets
alias ipInfo0='ipconfig getpacket en0'              # ipInfo0:      Get info on connections for en0
alias ipInfo1='ipconfig getpacket en1'              # ipInfo1:      Get info on connections for en1
alias openPorts='sudo lsof -i | grep LISTEN'        # openPorts:    All listening connections
alias showBlocked='sudo ipfw list'                  # showBlocked:  All ipfw rules inc/ blocked IPs
alias editHosts='sudo edit /etc/hosts'


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