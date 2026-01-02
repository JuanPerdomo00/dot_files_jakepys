#!/usr/bin/bash


DOTFILES_DIR="$HOME/jdotfiles"

link() {
    local src="$1"
    local dest="$2"
    local name="$3"
    
    mkdir -p "$(dirname "$dest")"
    
    ln -sf "$src" "$dest"
    echo "Add config $name"
}

link "$DOTFILES_DIR/dot_config/nvim" "$HOME/.config/nvim" "Neovim"
link  "$DOTFILES_DIR/dot_config/ghostty" "$HOME/.config/ghostty" "Terminal ghostty"
link  "$DOTFILES_DIR/dot_config/fastfetch" "$HOME/.config/fastfetch" "Fastfetch"
link  "$DOTFILES_DIR/dot_config/rofi" "$HOME/.config/rofi" "rofi"
link  "$DOTFILES_DIR/dot_config/starship" "$HOME/.config/starship" "starship"
link  "$DOTFILES_DIR/dot_config/niri" "$HOME/.config/niri" "niri"
link  "$DOTFILES_DIR/dot_config/waybar" "$HOME/.config/waybar" "waybar"
link  "$DOTFILES_DIR/dot_config/river" "$HOME/.config/river" "river"
link  "$DOTFILES_DIR/dot_config/kanshi" "$HOME/.config/kanshi" "kanshi"
link  "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc" "zsh config"
link  "$DOTFILES_DIR/.alias_zsh" "$HOME/.alias_zsh" "alias config"
link  "$DOTFILES_DIR/.function_zsh" "$HOME/.function_zsh" "function config"
link  "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig" ".gitconfig config"
link  "$DOTFILES_DIR/start_river" "$HOME/start_river" "River"

# Wallpapers
link  "$DOTFILES_DIR/wallpapers" "$HOME/.config/wallpapers" "Wallpapers"


echo "Good :D"
