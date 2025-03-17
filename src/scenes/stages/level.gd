extends Node2D

# Variables para la transición de la cámara
@export var transition_speed: float = 500.0  # Velocidad de la transición
var target_camera_position: Vector2 = Vector2.ZERO  # Posición objetivo de la cámara
var is_transitioning: bool = false  # Indica si la cámara está en transición
const screen_width = 1280
const screen_height = 720
var screen_x = 0
var screen_y = 0

# Referencia a la cámara
@onready var camera = $C/SVPC/SVP/Camera
@onready var player = $C/SVPC/SVP/Node2/Hen
func _ready():
	# Configurar la cámara al inicio
	camera.offset.x = 0

	# Mover la cámara inicialmente hacia la izquierda
	
	is_transitioning = true

func _process(delta: float):
	# Lógica para la transición suave de la cámara
	if is_transitioning:
		var new_position = camera.position.lerp(target_camera_position, transition_speed * delta)
		camera.position = new_position

		# Verificar si la cámara ha alcanzado la posición objetivo
		if camera.position.distance_to(target_camera_position) < 1.0:
			camera.position = target_camera_position
			is_transitioning = false

func move_camera(new_position: Vector2):
	# Establecer la posición objetivo y activar la transición
	target_camera_position = new_position
	is_transitioning = true

func spawn_player_after_delay(spawn_position: Vector2, delay: float = 0.5):
	# Ignorar inputs durante el retraso
	await get_tree().create_timer(delay).timeout
	
	# Spawnear la gallina en la nueva posición
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.position = spawn_position
		player.velocity = Vector2.ZERO  # Reiniciar velocidad

func _on_portal_entered(direction: String):
	
	# Mover la cámara según la dirección del portal
	match direction:
		"left":
			screen_x -=screen_width
			player.position.x -= 80
			
		"right":
			screen_x +=screen_width
			player.position.x += 80
		"up":
			screen_x +=screen_height
			player.position.y += 80
		"down":
			screen_x +=screen_height
			player.position.y -= 80
	move_camera(Vector2(screen_x, screen_y))
	
	# Spawnear la gallina después de un retraso

func on_Left_teleport(body: Node2D) -> void:
	print("Hen" in body.to_string())
	# Verificar si el cuerpo que entra es el jugador
	if "Hen" in body.to_string():
		print("me tocan")
		# Llamar a la función principal de manejo de portales
		_on_portal_entered("left")  # 1 representa el ID de la sala (ajusta según tu diseño)

func on_Right_teleport(body: Node2D) -> void:
	print("Hen" in body.to_string())
	# Verificar si el cuerpo que entra es el jugador
	if "Hen" in body.to_string():
		# Llamar a la función principal de manejo de portales
		_on_portal_entered("right")  # 2 representa el ID de la sala (ajusta según tu diseño)
