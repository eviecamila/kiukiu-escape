extends Node
const screen_width = 1280
const screen_height = 720
const tile_size = 40  # Tamaño de cada tile en el mapa
const SCALE_FACTOR = 2.0

const GAME_PATH = "/root/Stage/C/Game/SVP"
const STAGE_PATH = "/root/Stage"
var volume = 1.0
var sfx = 1.0

var touching = false:
	set = update_touching

var SFX = AudioStreamPlayer.new()

func update_touching(e):
	# Detectar si es touchpad o mando
	if  e is InputEventGesture or e is InputEventPanGesture or e is InputEventJoypadButton or e is InputEventJoypadMotion:
		touching = true
	else: touching = false

func _play_sound(audio_node:AudioStreamPlayer, path):
	if not audio_node:
		audio_node = SFX
	audio_node.stream = load("res://assets/audio/"+path)
	audio_node.seek(0)
	audio_node.play()
