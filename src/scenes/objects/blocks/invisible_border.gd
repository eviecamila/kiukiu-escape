extends Node2D
class_name InvisibleBorder

@export var x1: float = 0.0
@export var y1: float = 0.0
@export var x2: float = 0.0
@export var y2: float = 0.0
@export var thickness: float = 2.0

func _ready():
	# Configurar colisión al inicio
	setup_collision()

func setup_border(x1_new: float, y1_new: float, x2_new: float, y2_new: float) -> void:
	x1 = x1_new
	y1 = y1_new
	x2 = x2_new
	y2 = y2_new
	setup_collision()

func setup_collision():
	var area = $Area2D
	var collision_shape = area.get_node("CollisionShape2D")
	var rect_shape = RectangleShape2D.new()
	rect_shape.extents = Vector2(abs(x2 - x1)/2 + thickness/2, abs(y2 - y1)/2 + thickness/2)
	collision_shape.shape = rect_shape
	area.position = Vector2((x1 + x2)/2, (y1 + y2)/2)

	# Conectar señal de colisión solo si no está conectada
	if not area.is_connected("body_entered", Callable(self, "_on_body_entered")):
		area.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	if body.is_in_group("Actor"):
		# Detener movimiento de la gallina
		body.velocity = Vector2.ZERO
		body.position = body.position.snapped(Vector2.ONE)  # Asegurar posición fija
