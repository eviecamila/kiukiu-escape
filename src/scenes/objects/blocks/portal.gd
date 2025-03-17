extends Node2D

class_name Portal

@export var x1: float = 0.0
@export var y1: float = 0.0
@export var x2: float = 0.0
@export var y2: float = 0.0
@export var thickness: float = 2.0
@export var room_id: int = 0  # ID de la habitación destino
@export var direction: String = "left"  # Dirección del portal ("left", "right", "up", "down")

func setup_portal(x: float, y: float, width: float, height: float, target_room: int, portal_direction: String) -> void:
	x1 = x
	y1 = y
	x2 = x + width
	y2 = y + height
	room_id = target_room  # Asignar el ID de la habitación destino
	direction = portal_direction  # Asignar la dirección del portal
	setup_collision()

func setup_collision():
	var area = $Area2D
	var collision_shape = area.get_node("CollisionShape2D")
	var rect_shape = RectangleShape2D.new()
	
	# Calcular dimensiones a partir de x1, y1, x2, y2
	var calculated_width = abs(x2 - x1)
	var calculated_height = abs(y2 - y1)
	rect_shape.extents = Vector2(calculated_width / 2, calculated_height / 2)
	collision_shape.shape = rect_shape
	
	# Posicionar el área en el centro del portal
	area.position = Vector2(x1 + calculated_width / 2, y1 + calculated_height / 2)
	
	# Conectar señal de colisión
	area.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		emit_signal("portal_entered", room_id, direction)

signal portal_entered(room_id: int, direction: String)
