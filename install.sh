#!/usr/bin/bash
DOTFILES_DIR="$HOME/dot_files_jakepys"

link() {
    local src="$1"
    local dest="$2"
    local name="$3"
    
    if [ ! -e "$src" ]; then
        echo "✗ Error: $name - $src no existe"
        return 1
    fi
    
    mkdir -p "$(dirname "$dest")"
    
    [ -L "$dest" ] && rm "$dest"
    
    ln -sf "$src" "$dest"
    echo "✓ $name"
}

[ ! -d "$DOTFILES_DIR" ] && echo "Error: $DOTFILES_DIR no existe" && exit 1

link "$DOTFILES_DIR/dot_config/nvim" "$HOME/.config/nvim" "Neovim"
link "$DOTFILES_DIR/dot_config/ghostty" "$HOME/.config/ghostty" "Ghostty"
link "$DOTFILES_DIR/dot_config/fastfetch" "$HOME/.config/fastfetch" "Fastfetch"
link "$DOTFILES_DIR/dot_config/rofi" "$HOME/.config/rofi" "Rofi"
link "$DOTFILES_DIR/dot_config/starship" "$HOME/.config/starship" "Starship"
link "$DOTFILES_DIR/dot_config/niri" "$HOME/.config/niri" "Niri"
link "$DOTFILES_DIR/dot_config/waybar" "$HOME/.config/waybar" "Waybar"
link "$DOTFILES_DIR/dot_config/swaylock" "$HOME/.config/swaylock" "Swaylock"
link "$DOTFILES_DIR/dot_config/starship.toml" "$HOME/.config/starship.toml" "Swaylock"
link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc" "Zsh"
link "$DOTFILES_DIR/.alias_zsh" "$HOME/.alias_zsh" "Alias"
link "$DOTFILES_DIR/.function_zsh" "$HOME/.function_zsh" "Functions"
link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig" "Git"
link "$DOTFILES_DIR/wallpapers" "$HOME/.config/wallpapers" "Wallpapers"

echo "Listo :D"
