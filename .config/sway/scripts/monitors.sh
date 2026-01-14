#!/bin/bash

# use swaymsg -t get_outputs
LAPTOP="eDP-1"
EXTERNAL="HDMI-A-1"

if swaymsg -t get_outputs | grep -q "$EXTERNAL"; then
    swaymsg output $EXTERNAL enable pos 0 0 res 1920x1080@60Hz
    swaymsg output $LAPTOP disable
else
    swaymsg output $LAPTOP enable pos 0 0 res 1366x768@60Hz
fi
