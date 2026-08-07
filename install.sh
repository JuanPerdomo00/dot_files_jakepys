#!/usr/bin/bash
#
# Dotfiles Installation Arch by jakepys
# Copyright (C) 2026 
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

DOTFILES_DIR="$HOME/dot_files_jakepys"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}[✓]${NC} $1\n"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1\n"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1\n"
}

print_header() {
    echo -e "${BLUE}  $1${NC}\n"
}

SESSION_TYPE=""
WM_CHOICE=""

select_environment() {
    echo "Which display server would you like to use?"
    PS3="Choose an option (number): "
    
    select opt in "Wayland" "X11 / Xorg"; do
        case $opt in
            "Wayland")
                SESSION_TYPE="wayland"
                break
                ;;
            "X11 / Xorg")
                SESSION_TYPE="x11"
                break
                ;;
            *) print_error "Invalid option. Try again." ;;
        esac
    done

    print_header "Window Manager Selection"
    
    if [ "$SESSION_TYPE" = "wayland" ]; then
        echo "Which window manager do you want to install/configure?"
        select wm_opt in "Hyprland" "Sway" "Niri"; do
            case $wm_opt in
                "Hyprland"|"Sway"|"Niri")
                    WM_CHOICE=$(echo "$wm_opt" | tr '[:upper:]' '[:lower:]')
                    break
                    ;;
                *) print_error "Invalid option. Try again." ;;
            esac
        done
    else
        WM_CHOICE="i3"
        print_info "For X11, i3 is selected by default."
    fi

    print_success "Selected: $SESSION_TYPE with $WM_CHOICE"
}

install_tools() {
    print_header "Installing Paru"
    sudo pacman -S --needed --noconfirm git base-devel
    if ! command -v paru &> /dev/null; then
        cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru
        makepkg -si --noconfirm
        cd .. && rm -rf paru
    fi
    paru --version && print_success "Paru verified/installed"

    print_header "Installing common tools Arch"
    sudo pacman -S --needed --noconfirm \
        s-tui gdu dolphin nodejs npm curl wget unzip \
        python flameshot ghostty starship fastfetch zsh neovim fzf lsd bat \
        zip man tree pavucontrol blueman \
        mpd mpc pipewire wireplumber \
        most bluez bluez-utils btop networkmanager \
        brightnessctl gnome-bluetooth-3.0 micro blueberry kitty \
        matugen

    # Dependencias estrictamente separadas por entorno
    if [ "$SESSION_TYPE" = "wayland" ]; then
        print_header "Installing Wayland-specific tools"
        sudo pacman -S --needed --noconfirm \
            wayland xorg-xwayland xwayland-satellite swaybg mako foot wl-clipboard hyprpicker
            
        paru -S --needed --noconfirm \
            rofi-wayland cava-git grimblast gpu-screen-recorder swww dart-sass \
            rose-pine-cursor rose-pine-hyprcursor nwg-launchers

        if [ "$WM_CHOICE" = "hyprland" ]; then
            paru -S --needed --noconfirm hyprland-git hyprlock-git
        elif [ "$WM_CHOICE" = "sway" ]; then
            sudo pacman -S --needed --noconfirm sway swaylock
            paru -S --needed --noconfirm swaylock-effects
        elif [ "$WM_CHOICE" = "niri" ]; then
            paru -S --needed --noconfirm niri-git
        fi

    else
        print_header "Installing X11-specific tools"
        sudo pacman -S --needed --noconfirm \
            xorg-server xorg-xinit i3-wm i3lock i3status rofi dunst picom feh polybar
    fi
    
    print_header "Installing Fonts"
    sudo pacman -S --needed --noconfirm noto-fonts noto-fonts-cjk ttf-dejavu ttf-liberation ttf-font-awesome  nerd-fonts 
    
    print_header "Update Fonts"
    fc-cache -fv

    print_success "Tools installed successfully"
}

install_oh_my_zsh() {
    print_header "Installing Oh My Zsh"

    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_info "Oh My Zsh is already installed"
        return 0
    fi

    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" "" --unattended
    print_success "Oh My Zsh installed"
}

install_plugins_oh_my_zsh() {
    print_header "Installing Oh My Zsh plugins"

    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        print_success "zsh-autosuggestions installed"
    fi

    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting" ]; then
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
        print_success "fast-syntax-highlighting installed"
    fi
}

link() {
    local src="$1"
    local dest="$2"
    local name="$3"

    [ ! -e "$src" ] && print_error "$name - $src does not exist" && return 1

    mkdir -p "$(dirname "$dest")"
    [ -e "$dest" ] && rm -rf "$dest"

    ln -sf "$src" "$dest"
    print_success "$name"
}

create_symlinks() {
    print_header "Creating symbolic links"

    link "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim" "Neovim"
    link "$DOTFILES_DIR/.config/ghostty" "$HOME/.config/ghostty" "Ghostty"
    link "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty" "Kitty"
    link "$DOTFILES_DIR/.config/fastfetch" "$HOME/.config/fastfetch" "Fastfetch"
    link "$DOTFILES_DIR/.config/rofi" "$HOME/.config/rofi" "Rofi"
    link "$DOTFILES_DIR/.config/flameshot" "$HOME/.config/flameshot" "Flameshot"
    link "$DOTFILES_DIR/.config/git" "$HOME/.config/git" "Git"
    link "$DOTFILES_DIR/.config/gtk-3.0" "$HOME/.config/gtk-3.0" "GTK-3.0"
    link "$DOTFILES_DIR/.config/Kvantum" "$HOME/.config/Kvantum" "Kvantum"
    link "$DOTFILES_DIR/.config/qt5ct" "$HOME/.config/qt5ct" "Qt5ct"
    link "$DOTFILES_DIR/.config/qt6ct" "$HOME/.config/qt6ct" "Qt6ct"
    link "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml" "Starship Config"
    link "$DOTFILES_DIR/.config/zsh" "$HOME/.config/zsh" "ZSH configs"
    link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc" "Zsh file"
    link "$DOTFILES_DIR/wallpapers" "$HOME/.config/wallpapers" "Wallpapers"

    if [ "$SESSION_TYPE" = "wayland" ]; then
        link "$DOTFILES_DIR/.config/waybar" "$HOME/.config/waybar" "Waybar"
        link "$DOTFILES_DIR/.config/mako" "$HOME/.config/mako" "Mako"
        if [ "$WM_CHOICE" = "niri" ]; then
            link "$DOTFILES_DIR/.config/niri" "$HOME/.config/niri" "Niri"
        elif [ "$WM_CHOICE" = "sway" ]; then
            link "$DOTFILES_DIR/.config/sway" "$HOME/.config/sway" "Sway"
            link "$DOTFILES_DIR/.config/swaylock" "$HOME/.config/swaylock" "Swaylock"
        fi
    else
        link "$DOTFILES_DIR/.config/dunst" "$HOME/.config/dunst" "Dunst"
        link "$DOTFILES_DIR/.config/i3" "$HOME/.config/i3" "i3"
        link "$DOTFILES_DIR/.config/picom" "$HOME/.config/picom" "Picom"
        link "$DOTFILES_DIR/.config/polybar" "$HOME/.config/polybar" "Polybar"
    fi
}

change_shell() {
    print_header "Setting Zsh as default shell"

    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s $(which zsh)
        print_success "Default shell changed to Zsh"
    else
        print_info "Zsh is already your default shell"
    fi
}

main() {
    [ ! -d "$DOTFILES_DIR" ] && print_error "Directory $DOTFILES_DIR does not exist" && exit 1

    print_header "Starting dotfiles installation"

    select_environment
    install_tools
    install_oh_my_zsh
    install_plugins_oh_my_zsh
    create_symlinks
    change_shell

    print_header "Ok..."
    print_info "Run: exec zsh"
}

main
print_success "Done :D"
