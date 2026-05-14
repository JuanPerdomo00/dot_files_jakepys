#!/usr/bin/bash

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

install_tools() {
	print_header "Instaling Paru"
	sudo pacman -S --needed --noconfirm git base-devel
	cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru
	makepkg -si --noconfirm
	cd .. && rm -rf paru
	paru --version && print_success "Paru Installed"

	print_header "Installing tools"
	sudo pacman -S --needed --noconfirm \
		s-tui gdu mako xwayland-satellite dolphin swaybg nodejs npm curl wget unzip \
		python flameshot ghostty starship fastfetch zsh neovim rofi fzf lsd bat \
		zip man tree pavucontrol blueman \
		waybar foot mpd mpc ttf-font-awesome nerd-fonts pipewire wireplumber \
		nwg-launchers most swayfx bluez bluez-utils btop networkmanager \
		wl-clipboard brightnessctl gnome-bluetooth-3.0 aylurs-gtk-shell micro blueberry kitty \
		hyprpicker matugen

	paru -S swaylock-effects hyprlock-git rofi-wayland cava-git hyprland-git \
		rose-pine-cursor rose-pine-hyprcursor grimblast gpu-screen-recorder swww dart-sass
	print_success "Tools installed"
}

install_oh_my_zsh() {
	print_header "Installing Oh My Zsh"

	if [ -d "$HOME/.oh-my-zsh" ]; then
		print_info "Oh My Zsh already installed"
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
	link "$DOTFILES_DIR/.config/fastfetch" "$HOME/.config/fastfetch" "Fastfetch"
	link "$DOTFILES_DIR/.config/rofi" "$HOME/.config/rofi" "Rofi"
	link "$DOTFILES_DIR/.config/niri" "$HOME/.config/niri" "Niri"
	link "$DOTFILES_DIR/.config/waybar" "$HOME/.config/waybar" "Waybar"
	link "$DOTFILES_DIR/.config/swaylock" "$HOME/.config/swaylock" "Swaylock"
	link "$DOTFILES_DIR/.config/flameshot" "$HOME/.config/flameshot" "Flameshot"
	link "$DOTFILES_DIR/.config/mako" "$HOME/.config/mako" "Mako"
	link "$DOTFILES_DIR/.config/sway" "$HOME/.config/sway" "Sway"
	link "$DOTFILES_DIR/.config/git" "$HOME/.config/git" "Git"
	link "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml" "Starship Config"
	link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc" "Zsh"
	link "$DOTFILES_DIR/.alias_zsh" "$HOME/.alias_zsh" "Alias"
	link "$DOTFILES_DIR/.function_zsh" "$HOME/.function_zsh" "Functions"
	link "$DOTFILES_DIR/wallpapers" "$HOME/.config/wallpapers" "Wallpapers"
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
