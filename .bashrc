[ -f ~/.fzf.bash ] && source ~/.fzf.bash

HISTSIZE=2048

complete -o bashdefault -o default -o nospace -F __git_wrap__git_main g

eval "$(starship init bash)"

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# opencode
export PATH=/Users/dylan/.opencode/bin:$PATH

# z - directory jumper
source /opt/homebrew/etc/profile.d/z.sh

# pnpm
export PNPM_HOME="/Users/dylan/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"
