extends Node

signal display_dialog(text_key)

signal teleport(location)
signal sfx(path : String)
signal bgm(path : String)
signal ui_fade_in(duration: float)
signal ui_fade_out(duration: float)
signal input(action: InputEvent)
signal cam_smooth(val)
signal PC_CAM(val)
signal reset_game
