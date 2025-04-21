extends Control



@onready var test: Label = $Volume/test  # Asegúrate de que "test" sea un Label

# Índices de los buses de audio
var bgm_bus_index: int = AudioServer.get_bus_index("BGM")
var sfx_bus_index: int = AudioServer.get_bus_index("SFX")

func _ready():
	# Inicializar el texto del estado de pausa
	
	
	_on_SFX_slider_value_changed($Volume/sfx.value)
	_on_BGM_slider_value_changed($Volume/bgm.value)
	hide()
	
func _input(event: InputEvent):
	if not visible:
		return  # Ignora la entrada si el menú no está visible
	for key in ["pause", "btn_2"]:
		if event.is_action_pressed(key):
			handle_input(key);return
func handle_input(action: String):
	match action:
		"pause", "btn_2":_on_Continue_button_pressed()
	
	
func _on_Continue_button_pressed(): 
	hide()
	await get_tree().create_timer(0.1).timeout
	emit_signal("continued")

func _on_Settings_button_pressed():
	print('debe abrir menu w')
	# Abrir el menú de configuración
	pass

func _on_Respawn_button_pressed():
	emit_signal("continued")
	emit_signal("respawn")
	hide()
	
func _on_SFX_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		sfx_bus_index, linear_to_db(value/100)
	)
func _on_BGM_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		bgm_bus_index, linear_to_db(value/100)
	)
	 
func _on_Home_button_pressed():
	print('a casa pringao')
	# Regresar al menú principal
	var main_menu = load("res://scenes/MainMenu.tscn")
	get_tree().change_scene_to_packed(main_menu)



func _on_continue_mouse_entered() -> void:
	print('aaa me violan')
