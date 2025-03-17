extends Node2D

@export var transition_speed: float = 1500.0  
var target_camera_position: Vector2 = Vector2.ZERO  
var is_transitioning: bool = false  

const screen_width = 1280
const screen_height = 720
var screen_x = 0
var screen_y = 0

@onready var camera = $C/SVPC/SVP/Camera
@onready var player = $C/SVPC/SVP/Node2/Hen

func _ready():
	camera.offset.x = 0
	is_transitioning = false  # No iniciar en transición

func _process(delta: float):
	if is_transitioning:
		camera.position = camera.position.move_toward(target_camera_position, transition_speed * delta)

		# Verificar si la cámara ha llegado al destino
		if camera.position.distance_to(target_camera_position) < 1.0:
			camera.position = target_camera_position
			is_transitioning = false
			player.set_physics_process(true)

func move_camera(new_position: Vector2):
	# Solo permitir el movimiento si no está en transición
	if not is_transitioning:
		target_camera_position = new_position
		player.set_physics_process(false)
		is_transitioning = true

func _on_portal_entered(direction: String):
	if is_transitioning:
		return  # Evita entradas múltiples mientras la cámara aún se mueve

	print("Portal tocado:", direction)
	print("Antes -> screen_x:", screen_x, "screen_y:", screen_y)

	# Ajustar la posición del jugador antes de mover la cámara
	match direction:
		"left":
			screen_x -= screen_width
			player.position.x -= 80
		"right":
			screen_x += screen_width
			player.position.x += 80
		"up":
			screen_y -= screen_height
			player.position.y -= 80
		"down":
			screen_y += screen_height
			player.position.y += 80
	
	print("Después -> screen_x:", screen_x, "screen_y:", screen_y)

	# Mover la cámara solo después de actualizar la posición del jugador
	move_camera(Vector2(screen_x, screen_y))

func on_Left_teleport(body: Node2D) -> void:
	if "Hen" in body.to_string() and not is_transitioning:
		_on_portal_entered("left")

func on_Right_teleport(body: Node2D) -> void:
	if "Hen" in body.to_string() and not is_transitioning:
		_on_portal_entered("right")
