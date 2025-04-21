extends Area2D


# Señales personalizadas
signal pressed  # Emitida cuando el jugador presiona una tecla dentro del portal
signal entered  # Emitida cuando el jugador entra en el portal
signal exited
# Propiedades personalizadas para almacenar metadatos del portal
@export var target_room: Vector2 = Vector2.ZERO  # Coordenadas del room de destino
@export var target_coords: Vector2 = Vector2.ZERO  # Coordenadas dentro del room de destino
@export var inside:bool = false
# Tamaño del portal (ancho y alto)
@export var width: int = 40  # Ancho en píxeles
@export var height: int = 40  # Alto en píxeles

# Constructor para inicializar el portal
func _ready():
	# Crear la forma de colisión
	var collision_shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.extents = Vector2(width / 2, height / 2)  # Extensión de la forma rectangular
	collision_shape.shape = rectangle
	add_child(collision_shape)

	# Conectar señales para detectar entradas/salidas
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

# Método para configurar el portal dinámicamente
func setup_portal(x: int, y: int, target_room: Vector2, target_coords: Vector2, tile_size: int, _width, _height):
	# Configurar la posición del portal
	position = Vector2(x * tile_size, y * tile_size)
	width *= _width
	height *= _height
	# Configurar las propiedades del destino
	self.target_room = target_room
	self.target_coords = target_coords

func _input(event: InputEvent) -> void:
	if inside and event.is_action_pressed("btn_1"):
		emit_signal("pressed")

# Evento cuando un cuerpo entra en el portal
func _on_body_entered(body: Node2D):
	if "Hen" in body.to_string():
		emit_signal("entered")  # Emitir señal de entrada
		inside = true
		body.can_press("btn_1")

# Evento cuando un cuerpo sale del portal
func _on_body_exited(body: Node2D):
	if "Hen" in body.to_string():
		inside = false
		body.cant_press()
		
