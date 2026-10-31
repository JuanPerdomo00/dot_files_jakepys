if [[ -r "..." ]]; then source "..."; fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_CFG="$HOME/.config/zsh"
_load() { [[ -f "$1" ]] && source "$1" }

_load "$ZSH_CFG/plugins.zsh"
_load "$ZSH_CFG/exports.zsh"
_load "$ZSH_CFG/alias.zsh"
_load "$ZSH_CFG/functions.zsh"
_load "$ZSH_CFG/prompt.zsh"

FZF_ALT_C_COMMAND= source <(fzf --zsh)
[ -s "/home/jakepys/.bun/_bun" ] && source "/home/jakepys/.bun/_bun"

source /home/jakepys/.config/broot/launcher/bash/br
. "$HOME/.local/bin/env"


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/home/jakepys/.opam/opam-init/init.zsh' ]] || source '/home/jakepys/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null; true
# END opam configuration
