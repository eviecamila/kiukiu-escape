extends Node2D

@onready var eyes = $items/eyes

func _ready():
	setup_eyes()

func setup_eyes():
	# Inicializa el contador de ojos totales
	PlayerData.current_eyes_to_get = eyes.get_children().size()
	PlayerData.current_eyes_remaining = eyes.get_children().size()
	for eye in eyes.get_children():
		eye.connect("got", Callable(_on_eye_found))  # Conecta la señal de recolección
		eye.update_text()
	print("Faltan %d ojos" % [PlayerData.current_eyes_remaining])
func update_eyes_text():
	for eye in eyes.get_children():
		eye.update_text()
func _on_eye_found():
	# Reduce el contador de ojos restantes
	PlayerData.current_eyes_remaining -= 1
	print("Ojo recogido. Faltan %d ojos" % [PlayerData.current_eyes_remaining])
	update_eyes_text()
	# Opcional: Verifica si se completó el nivel
	if PlayerData.current_eyes_remaining <= 0:
		print("¡Nivel completado!")
