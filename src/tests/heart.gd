extends Node2D
class_name Heart

# Referencia al nodo AnimatedSprite2D y gold
@onready var sprite: AnimatedSprite2D = $Sprite  # Usar AnimatedSprite2D en lugar de Sprite2D
@onready var is_golden = self.get_meta("golden", false)  # Obtener el metadato "golden"

func _ready() -> void:
	# Validar que el sprite exista
	if sprite:
		# Configurar la animación inicial del corazón basada en el metadato "golden"
		if is_golden:
			sprite.play("gold_full")
		else:
			sprite.play("full")
		
		# Ocultar el corazón inicialmente
		self.visible = false
	else:
		push_error("El nodo AnimatedSprite2D no fue encontrado para el corazón:", self.name)

func update_health(s: int) -> void:
	# Actualizar la visibilidad y animación del corazón basada en el valor s (1 para visible, 0 para oculto)
	if is_golden:
		# Corazones dorados se ocultan cuando s es 0
		self.visible = s == 1
	else:
		# Corazones normales cambian a "empty" cuando s es 0
		if s == 0:
			sprite.play("empty")
		else:
			sprite.play("full")

func update_heart_visuals(v: int) -> void:
	# Actualizar la visibilidad del corazón basada en el valor v (1 para visible, 0 para oculto)
	self.visible = v == 1
