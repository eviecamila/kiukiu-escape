extends Node3D

# Referencias a Nodos
@onready var cam_pc: Camera3D = $PC_ENTITY/CAM
@onready var pc = $PC_ENTITY
@onready var game_ui = $PC_ENTITY/PC/INSERT_SCENE/GameUi
@onready var vp = $PC_ENTITY/PC/INSERT_SCENE
var scene = load("res://Elements/UI/game/GameUI.tscn")
# Constantes y Variables de Estado
var player_cam: Camera3D = null
var is_interacting: bool = false # Mantenida por si acaso, pero no usada en la lógica de entrada/salida

func _ready() -> void:
	vp.get_tree().paused=true
	# --- 1. CONFIGURACIÓN DEL VOLUMEN ---
	
	# --- 2. INICIALIZACIÓN ---
	# Obtener la cámara del jugador (Asume que es la cámara actual al inicio)
	player_cam = get_viewport().get_camera_3d()

# Función que maneja el cambio de valor del ScrollBar

# ======================================================================
# LÓGICA DE CÁMARA E INTERACCIÓN (Llamada desde el jugador)
# ======================================================================

# Función para cambiar entre la cámara del jugador y la cámara del PC
func toggle_pc_camera():
	if cam_pc.is_current():
		# SALIENDO DEL PC
		if player_cam:
			player_cam.set_current(true)
			print("Cambiando a cámara de Jugador.")
			SignalBus.emit_signal("PC_CAM", false) # AVISAR AL JUGADOR: DESACTIVADO
			
			# DEJA DE PAUSAR LA UI DEL PC (o restablece el modo de input)
			vp.get_tree().paused=true
	else:
		# ENTRANDO AL PC
		cam_pc.set_current(true)
		print("Cambiando a cámara de PC.")
		SignalBus.emit_signal("PC_CAM", true) # AVISAR AL JUGADOR: ACTIVADO
		vp.get_tree().paused=false # La UI del PC ahora está activa

# NUEVA FUNCIÓN PARA REINICIAR Y SALIR (Al presionar ESC)
func reset_and_exit_pc():
	print("PC: Reiniciando aplicación y saliendo.")
	
	# 1. ELIMINAR Y REINSTANCIAR LA UI
	
	var scene_path = vp.get_meta("scene") # Obtener la ruta de la escena guardada en la metadata de VP
	
	if not scene_path:
		# Fallback: Si no hay metadata, usa una ruta fija (si es conocida)
		scene_path = get_meta("scene", "res://Elements/UI/game/GameUI.tscn")
		print("ADVERTENCIA: Metadata 'scene' no encontrada en Viewport. Usando ruta fija.")

	var new_scene = load(scene_path)
	
	if new_scene:
		# a) Eliminar la instancia actual de la UI
		if game_ui:
			game_ui.queue_free()
			# Limpiamos la referencia para evitar errores
			game_ui = null
		
		# b) Instanciar la nueva escena y añadirla al Viewport (vp)
		var new_ui_instance = new_scene.instantiate()
		vp.add_child(new_ui_instance)
		
		# c) Actualizar la referencia global (para que toggle/input funcione)
		game_ui = new_ui_instance
		
		# Opcional: Pausar el nuevo árbol de UI hasta que se entre de nuevo
		game_ui.get_tree().paused = true 
		
	else:
		print("ERROR: No se pudo cargar o instanciar la escena UI desde:", scene_path)


	# 2. SALIR DEL MODO PC
	toggle_pc_camera()
	# No necesitamos cambiar el mouse mode aquí, ya que el jugador lo hará al detectar que pc_camera_is_active=false
func _input(event: InputEvent) -> void:
	
	if cam_pc.is_current():
		
		# --- 1. BLOQUEAR TODO EXCEPTO ui_cancel ---
		if event.is_action_pressed("ui_cancel"):
			# Si se presiona ESC, reiniciamos y salimos.
			reset_and_exit_pc()
			get_viewport().set_input_as_handled() # Consume el input para que no haga nada más
			return # Detener la propagación
			
		# --- 2. PROPAGACIÓN DE INPUT A LA UI (Solo si no es ui_cancel) ---
		# Solo se propagarán inputs esenciales para la UI (como ui_up/down/accept)
		for p in ["ui_accept", "ui_up", "ui_down", "ui_left", "ui_right",
		"btn_1", 'song_prev', 'song_next', "btn_reset"]: # <--- FILTRAMOS SOLO LOS NECESARIOS
			if event.is_action_pressed(p):
				
				SignalBus.emit_signal("input", event)
				get_viewport().set_input_as_handled() # Consume el input
				return # Detener la propagación
		
		# Cualquier otro input (btn_1, btn_reset, etc.) se bloquea porque no se propaga.
		get_viewport().set_input_as_handled()
