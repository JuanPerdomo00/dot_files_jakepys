------------------------------
---- LID SWITCH           ----
------------------------------


-- Tapa cerrada -> apaga la pantalla del portátil
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprctl keyword monitor eDP-1,disable"), { locked = true })

-- Tapa abierta -> vuelve a prender la pantalla del portátil
-- (1366x768 es la resolución nativa real de esta pantalla, confirmada con `hyprctl monitors all`)
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl keyword monitor eDP-1,1366x768@60,0x0,1"), { locked = true })
