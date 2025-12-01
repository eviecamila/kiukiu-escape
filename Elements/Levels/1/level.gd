extends Node2D

# NOTA SOBRE LA CÁMARA:
# Para que el clamping (límites) funcione correctamente, es muy recomendable 
# que 'Cam' sea un nodo hijo directo de 'Level' ($Cam), no del 'Player'.

@onready var fade_manager: CanvasLayer = $"../FadeCanvas"
@export var player_target: CharacterBody2D # Se asigna el nodo Player en el editor

# Rectángulo que define los límites de la habitación actual.
var current_limits_rect: Rect2 = Rect2()

# Estado de control de la cámara
var is_in_transition: bool = false
var is_teleporting:bool = false
# Duración del FADE IN y FADE OUT (ej: 0.5s IN + 0.5s OUT = 1.0s total)
const TRANSITION_TIME: float = 0.5 

func _ready():
	# 1. Activamos la cámara
	SignalBus.teleport.connect(_on_teleport)
	# 2. Inicializamos el primer checkpoint
	if player_target:
		Global.set_checkpoint(player_target.global_position)
		
	# 3. Opcional: Centrar inmediatamente la cámara en el jugador al inicio
	# cam.global_position = player_target.global_position

func _physics_process(_delta: float) -> void:
	if not player_target:
		return

	# 🚨 CORRECCIÓN CLAVE: Si estamos en transición, NO HACEMOS NADA.
	# Dejamos que la función async controle la posición de la cámara.
	if is_in_transition:
		return

	var target_pos: Vector2
	
	# Modo de Seguimiento normal: sigue al jugador
	target_pos = player_target.global_position
		
	# 2. Aplicar Límites (Clamping) - SIN CAMBIOS
# Conecta la señal 'room_entered(new_room_rect)' de CADA Room_Trigger a esta función.
func on_room_trigger_entered(new_room_rect: Rect2):
	
	if is_in_transition:
		return

	is_in_transition = true
	
	# 1. Iniciar el FADE IN (La pantalla se pone negra)
	# La función do_fade devolverá un awaitable que terminará al final del FADE OUT.
	var fade_process = fade_manager.do_fade(TRANSITION_TIME)
	
	# 2. Esperar la señal: La pantalla está COMPLETAMENTE negra.
	# Esta señal es emitida por FadeManager a mitad de la transición.
	await fade_manager.fully_faded_in
	
	# 3. Mover la cámara (INSTANTÁNEO)
	current_limits_rect = new_room_rect # Actualiza los nuevos límites de la sala
	var new_camera_center = current_limits_rect.get_center()
	
	
	# 4. Opcional: Teletransportar el jugador (si el teletransporte debe ser invisible)
	# player_target.global_position = new_camera_center 
	
	# 5. Esperar a que el FADE OUT termine (esperando a que termine toda la función do_fade)
	await fade_process
	
	# 6. Finalizar la transición (Devuelve el control al seguimiento del jugador)
	is_in_transition = false
# Asumimos que este código está en el script que detecta el portal,
# y que tienes una referencia a la cámara activa del jugador.

# La función do_fade se reemplaza por la secuencia: Fade In -> Mover -> Fade Out

func _on_teleport(location):
	# 1. Indicamos que el jugador está en transición (para pausar el input)
	is_teleporting = true
	$Player.set_physics_process(false)
	# --- FASE 1: FADE OUT (Pantalla a Negro) ---
	# Asume que 'fade_manager' es la referencia al nodo que contiene Fade_Canvas.gd
	
	# 2. Inicia el Fade In y espera a que el Tween termine (pantalla negra)
	# Debemos obtener el objeto Tween y luego esperar su señal 'finished'.
	var fade_tween = fade_manager.fade_in_to_black(0.5)
	await fade_tween.finished
	
	# 3. Mover a la Coco (Kiu) de forma instantánea
	
	# Asegúrate de usar la ruta correcta a la cámara ($Player/CAM_2_5D o similar)
	$Player/cam.set_position_smoothing_enabled(false) 
	
	# Mueve al jugador a la nueva ubicación
	$Player.position = location
	
	# Espera un frame para que Godot registre el nuevo transform
	await get_tree().process_frame 
	
	
	
	# --- FASE 2: FADE IN (Revelar Escena) ---
	
	is_teleporting = false
	
	# 4. Inicia el Fade Out y espera a que el Tween termine (pantalla visible)
	var reveal_tween = fade_manager.fade_out_from_black(0.5)
	await reveal_tween.finished
	$Player.set_physics_process(true)
	$Player/cam.set_position_smoothing_enabled(true)
	print("Teletransporte completado.")
