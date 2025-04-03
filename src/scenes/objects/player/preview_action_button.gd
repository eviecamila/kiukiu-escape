extends Node2D

# Exportar propiedades
@export var animation: String = "kb_z"  # Animación a usar (aunque no se usará animación)
@onready var animated_sprite: AnimatedSprite2D = $btn

# Estado de visibilidad
var is_visible_on_screen: bool = false:
	set = set_is_visible_on_screen

func _ready():
	# Configurar el sprite inicialmente invisible
	modulate.a = 0.0  # Inicialmente transparente

func can_press(button: String) -> void:
	# Mostrar el botón
	show_btn()

func cant_press() -> void:
	# Ocultar el botón
	hide_btn()

func set_is_visible_on_screen(value: bool) -> void:
	if value == is_visible_on_screen:
		return
	is_visible_on_screen = value
	if value:
		show_button()
	else:
		hide_button()

func show_button() -> void:
	# Hacer visible el botón
	modulate.a = 1.0
	animated_sprite.visible = true

func hide_button() -> void:
	# Ocultar el botón
	modulate.a = 0.0
	animated_sprite.visible = false

func show_btn() -> void:
	set_is_visible_on_screen(true)

func hide_btn() -> void:
	set_is_visible_on_screen(false)
