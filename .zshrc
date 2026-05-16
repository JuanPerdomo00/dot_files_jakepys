if [[ -r "..." ]]; then source "..."; fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_CFG="$HOME/.config/zsh"
_load() { [[ -f "$1" ]] && source "$1" }

_load "$ZSH_CFG/plugins.zsh"
_load "$ZSH_CFG/exports.zsh"
_load "$ZSH_CFG/aliases.zsh"
_load "$ZSH_CFG/functions.zsh"
_load "$ZSH_CFG/prompt.zsh"

FZF_ALT_C_COMMAND= source <(fzf --zsh)
[ -s "/home/jakepys/.bun/_bun" ] && source "/home/jakepys/.bun/_bun"
