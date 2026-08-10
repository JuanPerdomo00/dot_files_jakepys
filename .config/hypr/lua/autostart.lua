-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

local programs = require("programs")

hl.on("hyprland.start", function ()
    --   hl.exec_cmd(programs.terminal)
    --   hl.exec_cmd("nm-applet")
    hl.exec_cmd("waybar")
    hl.exec_cmd("kanshi")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd(
        "sh -c 'sleep 1 && /home/jakepys/dot_files_jakepys/.config/hypr/scripts/change_wallpapers.py ~/Pictures/wallpapers 3600'"
    )
end)
