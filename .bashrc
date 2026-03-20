[ -f ~/.fzf.bash ] && source ~/.fzf.bash

HISTSIZE=2048

complete -o bashdefault -o default -o nospace -F __git_wrap__git_main g

eval "$(starship init bash)"

# opencode
export PATH=$HOME/.opencode/bin:$PATH
