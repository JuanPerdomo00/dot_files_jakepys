# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
eval "$(starship init zsh)"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
ZSH_THEME=""


plugins=(
    git
    zsh-autosuggestions
    fast-syntax-highlighting
    colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# User configuration


# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='nvim'
else
    export EDITOR='nvim'
fi



# fzf
FZF_ALT_C_COMMAND= source <(fzf --zsh)

# PATH
export PATH="$PATH:/home/Jakepys/.local/bin:/usr/local/go/bin:/home/Jakepys/.deno/bin:/home/Jakepys/go/bin/:/home/jakepys/.nimble/bin"
#alias k=kubectl
#compdef __start_kubectl k
#"/home/Jakepys/.deno/env"
# Go Bin
export GOPATH=$HOME/go

if [ -f ~/.banner_zsh ]; then
	source ~/.banner_zsh

fi

# config alias and function
if [ -f ~/.alias_zsh ]; then
    source ~/.alias_zsh
fi

# Cargar funciones
if [ -f ~/.function_zsh ]; then
    source ~/.function_zsh
fi


export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export PATH=$PATH:~/.zig_versions

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
