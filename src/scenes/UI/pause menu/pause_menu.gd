extends Control

# Importar el autoload
var game_stats = preload("res://src/autoload/player_data.gd").new()
signal continued
signal respawn

@onready var test: Label = $Volume/test  # Asegúrate de que "test" sea un Label

# Índices de los buses de audio
var bgm_bus_index: int = AudioServer.get_bus_index("Master/BGM")
var sfx_bus_index: int = AudioServer.get_bus_index("Master/SFX")

func _ready():
	# Inicializar el texto del estado de pausa
	update_pause_status()

func _on_Continue_button_pressed():
	print('debe continuar w')
	# Reanudar el juego
	get_tree().paused = false
	emit_signal("continued")
	update_pause_status()  # Actualizar el estado de pausa

func _on_Settings_button_pressed():
	print('debe abrir menu w')
	# Abrir el menú de configuración
	pass

func _on_Respawn_button_pressed():
	print('debe morir la que seduzco w')
	# Reiniciar la partida
	get_tree().paused = false
	hide()
	game_stats.reset_data()
	emit_signal("respawn")
	update_pause_status()  # Actualizar el estado de pausa

func _on_SFX_slider_value_changed(value):
	# Ajustar el volumen del SFX
	if sfx_bus_index != -1:
		AudioServer.set_bus_volume_db(sfx_bus_index, value)

func _on_BGM_slider_value_changed(value):
	# Ajustar el volumen del BGM
	if bgm_bus_index != -1:
		AudioServer.set_bus_volume_db(bgm_bus_index, value)

func _on_Home_button_pressed():
	print('a casa pringao')
	# Regresar al menú principal
	var main_menu = load("res://scenes/MainMenu.tscn")
	get_tree().change_scene_to_packed(main_menu)

func update_pause_status():
	# Actualizar el texto del nodo "test" con el estado de pausa
	if PlayerData.debug:
		test.text = "Paused: " + str(get_tree().paused)
