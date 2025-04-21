extends Node2D

@onready var eyes = $items/eyes
@onready var golden_eggs = $items/golden_eggs
@onready var ground:TileMap = $Ground
@onready var startpos:Node2D = $StartPos
signal completed
signal animation(function)

func _ready():
	print("poniendo cell")
	setup_eyes()
	

func setup_eyes():
	# Inicializa el contador de ojos totales
	PlayerData.current_eyes_to_get = eyes.get_children().size()
	PlayerData.current_eyes_remaining = eyes.get_children().size()
	for eye in eyes.get_children():
		if not eye.visible:
			PlayerData.current_eyes_remaining-=1
			PlayerData.current_eyes_to_get-=1
			continue
		eye.connect("got", Callable(_on_eye_found))  # Conecta la señal de recolección
	update_eyes_text()
		
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
		emit_signal("animation", Callable(on_eyes_collected))


func on_eyes_collected(camera:Camera2D, x, y, width, height, bg):
	var prev_pos = Vector2(width*x, height*y)
	var pos = Vector2(width*2, height*3)

	if prev_pos !=pos:
		camera.position = pos
		bg.position = pos
	await get_tree().create_timer(1).timeout
	for i in range(67,54, -1):
		await get_tree().create_timer(.14).timeout
		$SFX.play()
		ground.set_cell(0, Vector2i(93 ,i), -1, Vector2i(4,0)) #Quitar bloques
	$SFX.stream = load("res://assets/audio/typing/2.wav")
	$SFX.play()
	await get_tree().create_timer(1).timeout
	if prev_pos !=pos:
		camera.position = prev_pos
		bg.position = prev_pos
func _on_goal() -> void:
	emit_signal("completed")
