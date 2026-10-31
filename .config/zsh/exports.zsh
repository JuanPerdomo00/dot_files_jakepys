if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='nvim'
else
    export EDITOR='nvim'
fi
 
export GOPATH="$HOME/go"
 
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
 
export GEM_HOME="$HOME/.local/share/gem/ruby/3.4.0"
export GEM_PATH="$GEM_HOME"
export PATH="$GEM_HOME/bin:$PATH"

export FZF_DEFAULT_OPTS="
  --color=bg:#120a24,bg+:#2d2260,fg:#e8d8ff,fg+:#ffffff
  --color=hl:#c04df0,hl+:#ff6ec7
  --color=info:#8ff0d8,prompt:#ff6ec7,pointer:#ff6ec7
  --color=marker:#a8f0a0,spinner:#ffc857,header:#9a84c9
  --color=border:#4a2c82,gutter:#120a24,label:#c4a8ff
"

export PATH="$PATH:\
/home/jakepys/.local/bin:\
/usr/local/go/bin:\
/home/jakepys/.deno/bin:\
/home/jakepys/go/bin:\
/home/jakepys/.cargo/bin:\
$HOME/.zig_versions:\
$HOME/.nimble/bin"
