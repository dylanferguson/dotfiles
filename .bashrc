# Run twolfson/sexy-bash-prompt
. ~/.bash_prompt

eval "$(thefuck --alias)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

HISTSIZE=2048

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
