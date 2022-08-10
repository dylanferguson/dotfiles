# Run twolfson/sexy-bash-prompt
# . ~/.bash_prompt

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

HISTSIZE=2048

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

complete -o bashdefault -o default -o nospace -F __git_wrap__git_main g

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

eval "$(starship init bash)"
