extends Area2D
class_name Item

@export var speed: float = 200.0
@export var collision_radius: float = 10.0
@export var is_active: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = collision_radius

func _process(delta: float) -> void:
	if is_active:
		update_position(delta)
		check_deactivation()

func update_position(delta: float) -> void:
	# Movimiento básico (puede ser sobreescrito)
	position += Vector2.RIGHT * speed * delta

func check_deactivation() -> void:
	# Desactivar si está 3 veces la distancia de la cámara
	if get_viewport().get_camera_2d():
		var camera_pos = get_viewport().get_camera_2d().global_position
		var distance = global_position.distance_to(camera_pos)
		if distance > get_viewport().size.length() * 3:
			is_active = false

func set_is_active(value: bool) -> void:
	is_active = value
	visible = value
	collision_shape.disabled = not value

func on_collision(area: Area2D) -> void:
	pass
