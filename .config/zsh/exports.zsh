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

export PATH="$PATH:\
/home/jakepys/.local/bin:\
/usr/local/go/bin:\
/home/jakepys/.deno/bin:\
/home/jakepys/go/bin:\
/home/jakepys/.cargo/bin:\
$HOME/.zig_versions"

