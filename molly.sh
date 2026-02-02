#!/bin/bash
# molly - shh configurator for github
# Copyright (C) 2026  Jakepys - Juan Perdomo
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Colors ansii
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RESET='\033[0m'

banner() {
	echo -e "${YELLOW}███╗   ███╗ ██████╗ ██╗     ██╗  ██╗   ██╗${RESET}"
	echo -e "${YELLOW}████╗ ████║██╔═══██╗██║     ██║  ╚██╗ ██╔╝${RESET}"
	echo -e "${YELLOW}██╔████╔██║██║   ██║██║     ██║   ╚████╔╝ ${RESET}"
	echo -e "${YELLOW}██║╚██╔╝██║██║   ██║██║     ██║    ╚██╔╝  ${RESET}"
	echo -e "${YELLOW}██║ ╚═╝ ██║╚██████╔╝███████╗███████╗██║   ${RESET}"
	echo -e "${YELLOW}╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚═╝   ${RESET}"
	echo -e "${GREEN}Configure your SSH github key easily.${RESET}\n"
}

encryption_algorithms() {
	echo -e "${YELLOW}[0]${RESET} ${GREEN}dsa (Not admitted in github)${RESET}"
	echo -e "${YELLOW}[1]${RESET} ${GREEN}ecdsa${RESET}"
	echo -e "${YELLOW}[2]${RESET} ${GREEN}ecdsa-sk${RESET}"
	echo -e "${YELLOW}[3]${RESET} ${GREEN}ed25519${RESET}"
	echo -e "${YELLOW}[4]${RESET} ${GREEN}ed25519-sk${RESET}"
	echo -e "${YELLOW}[5]${RESET} ${GREEN}rsa${RESET}"
	echo -e "${YELLOW}[q/exit]${RESET} ${GREEN}To exit${RESET}"
}

log() {
	type=$1
	msg=$2
	case "$1" in
	"warning")
		echo -e "[!] ${YELLOW}${msg}${RESET}"
		;;
	"success")
		echo -e "[+] ${GREEN}${msg}${RESET}"
		;;
	"error")
		echo -e "[x] ${RED}${msg}${RESET}"
		;;
	*) ;;
	esac
}

generate_key() {
	algorithm=$1
	email=$2
	key_file=""

	case "$algorithm" in
	"0")
		log "error" "DSA is not supported by GitHub"
		return 1
		;;
	"1")
		key_file="$HOME/.ssh/id_ecdsa"
		ssh-keygen -t ecdsa -b 521 -C "$email" -f "$key_file"
		;;
	"2")
		key_file="$HOME/.ssh/id_ecdsa_sk"
		ssh-keygen -t ecdsa-sk -C "$email" -f "$key_file"
		;;
	"3")
		key_file="$HOME/.ssh/id_ed25519"
		ssh-keygen -t ed25519 -C "$email" -f "$key_file"
		;;
	"4")
		key_file="$HOME/.ssh/id_ed25519_sk"
		ssh-keygen -t ed25519-sk -C "$email" -f "$key_file"
		;;
	"5")
		key_file="$HOME/.ssh/id_rsa"
		ssh-keygen -t rsa -b 4096 -C "$email" -f "$key_file"
		;;
	*)
		log "error" "Invalid option"
		return 1
		;;
	esac

	if [ $? -eq 0 ]; then
		log "success" "SSH key generated successfully!"

		eval "$(ssh-agent -s)" >/dev/null 2>&1
		ssh-add "$key_file" 2>/dev/null

		echo -e "\n${GREEN}Your public key:${RESET}"
		cat "${key_file}.pub"

		wl-copy <"${key_file}.pub"
		log "success" "Public key copied to clipboard"
	fi
}

main() {
	if [ -d ~/.ssh ] && ls ~/.ssh/id_* >/dev/null 2>&1; then
		log "warning" "It looks like you already have SSH keys."
		echo -n "Do you want to continue anyway? [y/N]: "
		read confirm
		if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
			log "success" "Bye"
			exit 0
		fi
	fi

	banner

	option=""
	email=""

	while true; do
		encryption_algorithms
		echo -n "Enter an option [0-5]: "
		read option

		if [[ "$option" == "q" ]] || [[ "$option" == "exit" ]]; then
			log "success" "Bye"
			exit 0
		fi

		if [[ ! "$option" =~ ^[0-5]$ ]]; then
			log "error" "Invalid option. Please select 0-5"
			continue
		fi

		echo -n "Enter an email address [Ex: test@test.com]: "
		read email

		if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
			log "error" "Invalid email format"
			continue
		fi

		generate_key "$option" "$email"
	done
}

main
