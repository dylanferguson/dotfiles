[ -f ~/.fzf.bash ] && source ~/.fzf.bash

HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth
shopt -s histappend

complete -o bashdefault -o default -o nospace -F __git_wrap__git_main g

eval "$(starship init bash)"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# z - directory jumper
source /opt/homebrew/etc/profile.d/z.sh

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"

# mise — host-managed runtimes (node, bun, go, rust, hugo, pnpm)
# Activated after everything else that touches PATH, so the block below has
# the final say on ordering.
eval "$(mise activate bash)"

# `mise activate` only puts the real versions in front from its prompt hook,
# and appends the shims *behind* ~/.local/bin as the fallback. Nothing without
# a prompt runs that hook — git hooks, editors, coding agents — so there `node`
# resolved to the copy Hermes symlinks into ~/.local/bin, which is a version
# behind and fails pnpm's engines check. The shims need no hook, so move them
# to the front and let them be the fallback everywhere.
mise_shims="$HOME/.local/share/mise/shims"
mise_rest=""
IFS=: read -ra mise_entries <<< "$PATH"
for mise_entry in "${mise_entries[@]}"; do
  [ "$mise_entry" = "$mise_shims" ] && continue
  mise_rest="${mise_rest:+$mise_rest:}$mise_entry"
done
export PATH="$mise_shims:$mise_rest"
unset mise_shims mise_rest mise_entries mise_entry
