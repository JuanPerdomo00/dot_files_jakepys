if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='nvim'
else
    export EDITOR='nvim'
fi
 
export GOPATH="$HOME/go"
 
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
 
export PATH="$PATH:\
/home/Jakepys/.local/bin:\
/usr/local/go/bin:\
/home/Jakepys/.deno/bin:\
/home/Jakepys/go/bin:\
/home/jakepys/.cargo/bin:\
$HOME/.zig_versions"

