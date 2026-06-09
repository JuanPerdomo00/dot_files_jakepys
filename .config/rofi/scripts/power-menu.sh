#!/bin/bash

poweroff_command="loginctl poweroff"
reboot_command="loginctl reboot"
logout_command="i3-msg exit"
hibernate_command="loginctl hibernate"
suspend_command="loginctl suspend"

rofi_command="rofi -width 5 -hide-scrollbar"

options=$'⏻ poweroff\n reboot\n󰍃 logout\n hibernate\n󰒲 suspend'

chosen="$($rofi_command -dmenu -p "" <<< "$options")"

[ -z "$chosen" ] && exit 0

action="${chosen##* }"

varname="${action}_command"
command="${!varname}"

[ -n "$command" ] && $command
