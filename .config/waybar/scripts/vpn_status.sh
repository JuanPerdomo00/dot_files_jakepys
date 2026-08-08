#!/bin/bash
# Uses the official Proton VPN CLI (proton-vpn-cli from AUR)

# Get current VPN status with icon
get_vpn_status() {
    STATUS=$(protonvpn-cli status 2>/dev/null)

    if echo "$STATUS" | grep -q "^Status: Connected"; then
        echo "󰖂 VPN"
    else
        echo "󰖑 VPN"
    fi
}

# Toggle VPN connection
toggle_vpn() {
    STATUS=$(protonvpn status 2>/dev/null)

    if echo "$STATUS" | grep -q "^Status: Connected"; then
        if protonvpn disconnect >/dev/null 2>&1; then
            notify-send -u normal "VPN Disconnected" "Proton VPN session ended"
        else
            notify-send -u critical "VPN Error" "Failed to disconnect"
        fi
    else
        if protonvpn connect --fastest >/dev/null 2>&1; then
            notify-send -u normal "VPN Connected" "Proton VPN session started"
        else
            notify-send -u critical "VPN Error" "Failed to connect"
        fi
    fi
}

case "$1" in
    --toggle)
        toggle_vpn
        ;;
    *)
        get_vpn_status
        ;;
esac
