# portal.gd - Aplicado al nodo raíz Area2D 'Portal'
extends Area2D

# --- Configuración del Portal ---

@export var player_group: String = "player" 
@export var activation_action: String = "btn_1" 

@onready var pvb = $PreviewButton
@onready var destination_node = $Destination
# --- Variables de Estado ---

var is_player_in_range: bool = false
var is_teleporting: bool = false # Bloquea múltiples activaciones
# --- Inicialización ---

func _ready() -> void:
	pvb.visible=false
	# Conectamos las señales de detección de área en Godot 4
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Verificación de asignación crucial
	if not destination_node:
		printerr("ERROR: El portal '" + name + "' no tiene asignado un Destination Node en el Inspector.")
	SignalBus.connect("input", _input)
# --- Detección de Input (Activación) ---

func _input(event: InputEvent) -> void:
	# 1. Verifica si el jugador está en rango y si se presiona la acción.
	if is_player_in_range and not is_teleporting and event.is_action_pressed(activation_action):
		
		# 🚨 SOLUCIÓN AL ERROR NIL: Verifica que destination_node no sea null
		if destination_node:
			# El portal se bloquea y emite el evento.
			is_teleporting = true
			
			# Emitimos el destino al Level Manager.
			SignalBus.teleport.emit(destination_node.global_position)
		else:
			# Evita el error si se pulsa antes de asignar en el editor.
			printerr("ERROR: Intento de teletransporte fallido. Destination Node no asignado.")


# --- Detección de Área ---

func _on_body_entered(body: Node2D) -> void:
	# Solo el jugador activa el Preview Button y el rango
	pvb.visible=true
	is_player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	pvb.visible=false
	is_player_in_range = false
	is_teleporting = false
