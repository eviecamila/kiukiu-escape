# Camera_Maestra.gd
extends Camera2D

# Variable que asignamos al nodo Player en el editor del nivel.
@export var target: Node2D = null

# Rectángulo que define los límites de la habitación actual.
# Se actualiza por el Room_Trigger.
var current_limits_rect: Rect2 = Rect2()

# Para el control de movimiento
var is_in_transition: bool = false
const TRANSITION_TIME: float = 0.5 # Tiempo para la transición de snap/pan

func _physics_process(delta: float) -> void:
	if target and not is_in_transition:
		# Modo 1: Seguir al jugador
		global_position = target.global_position
		
	# La suavidad del seguimiento al target se maneja automáticamente 
	# por la propiedad Position Smoothing activada en el Inspector.

	# 1. Aplicar los límites de la habitación (Limit Property)
	if current_limits_rect.has_area():
		limit_left = int(current_limits_rect.position.x)
		limit_top = int(current_limits_rect.position.y)
		limit_right = int(current_limits_rect.end.x)
		limit_bottom = int(current_limits_rect.end.y)
