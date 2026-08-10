------------------------------
---- LID SWITCH           ----
------------------------------

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprctl keyword monitor eDP-1,disable"), { locked = true })

hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl keyword monitor eDP-1,1366x768@60,0x0,1"), { locked = true })
