#!/usr/bin/bash

pkill -SIGTERM kanshi

riverctl spawn "kanshi &"
riverctl spawn "waybar &"
riverctl spawn "swaybg -m fill -i $HOME/.config/wallpapers/arch-waffiu.jpg &"
