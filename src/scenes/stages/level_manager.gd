extends Node2D 

@export var transition_speed: float = 1500.0  
var target_camera_position: Vector2 = Vector2.ZERO  
var is_transitioning: bool = false  

const screen_width = 1280
const screen_height = 720
const tile_size = 40  # Tamaño de cada tile en el mapa
const SCALE_FACTOR = 2.0
var room_x = 0
var room_y = 0
var screen_x = 0
var screen_y = 0

var current_npcs = []  # Almacena referencias a los NPCs actuales
var current_portals = []  # Almacena referencias a los portales actuales
var LR_Pressed = false
var current_song = ""

@onready var player = $C/Game/SVP/Node2/Hen

@onready var camera = $C/Game/SVP/Camera

#UI
@onready var BG = $C/Game/SVP/BG
@onready var BGM: AudioStreamPlayer= $BGM
@onready var FADE = $C/Game/SVP/Fade
@onready var DIALOG  = $UI/NpcDialog
@onready var TOPBAR = $UI/TopBar

@onready var game = $C/Game/SVP/Node2  # Asegúrate de que sea un nodo adecuado
@onready var npcs_script = get_node("/root/Stage/C/Game/SVP/Camera/Npcs")  # Referencia al nodo con npcs.gd
@onready var bgm_sounds = "res://assets/audio/soundtrack/"  # Referencia al nodo con npcs.gd
@onready var pause_screen = $UI/Pause
@onready var map_inv_menu = $UI/MapMenu

func _ready():
	var debug = PlayerData.debug
	
	get_tree().set_debug_collisions_hint(debug) 
	$UI/teleporter.visible = debug
	$UI/room.visible = debug
	# Configurar el menú de pausa
	setup_pause_screen()
	
	# Configuraciones iniciales
	camera.offset.x = 0
	is_transitioning = false
	load_npcs_for_current_room()
	load_portals_for_current_room()
	set_start_pos()
	

func setup_pause_screen():
	# Ocultar el menú de pausa al inicio
	pause_screen.visible = false

	# Conectar señales del menú de pausa
	pause_screen.connect("continued", Callable(self, "on_pause_continued"))
	pause_screen.connect("respawn", Callable(self, "on_respawn"))

func on_respawn(): player.die()
func on_pause_continued():set_pause_visibility(false)

func set_pause_visibility(visible: bool):
	pause_screen.visible = visible  # Mostrar u ocultar el menú de pausa
	get_tree().paused = visible  # Pausar/reanudar el nodo `game`


func _input(event):
	# MAP MENU / INVENTORY PRESSED
	if event.is_action_pressed("ui_map"):
		if get_tree().paused:
			return  # Ignora la entrada cuando el juego está pausado
		toggle_menu()
		
	# PAUSE MENU PRESSED
	if event.is_action_pressed("pause"):
		if not pause_screen.visible:
			# Mostrar el menú de pausa y emitir la señal "paused"
			set_pause_visibility(true)
			pause_screen.emit_signal("paused")
		else:
			# Ocultar el menú de pausa y emitir la señal "continued"
			set_pause_visibility(false)
			pause_screen.emit_signal("continued")
var can_pause = true
func toggle_menu():
	# Solo alterna el estado de pausa si se permite
	if not can_pause:
		return
	
	# Alterna el estado de pausa
	can_pause = false  # Bloquea la pausa temporalmente
	get_tree().paused = not get_tree().paused
	print("Estado de pausa:", get_tree().paused)
	
	# Si el juego está pausado, muestra el menú; si no, ocúltalo
	if get_tree().paused:
		TOPBAR.hide()
		map_inv_menu.show()  # Muestra el menú
	else:
		TOPBAR.show()
		map_inv_menu.hide()  # Oculta el menú
	
	# Restablece el permiso para pausar después de un breve retraso
	await get_tree().create_timer(0.1).timeout  # Espera 0.1 segundos
	can_pause = true

func set_start_pos():
	player.start_pos = Vector2(player.position.x, player.position.y + 20)

# Mover los elementos de UI
func set_UI_pos():
	for ui_item in [BG, FADE]:
		ui_item.position = camera.position
func _process(delta: float):
	var cc_x = int(abs(player.position.x)/tile_size)%32
	var cc_y = int(abs(player.position.y)/tile_size)%18

	$UI/room.text = "Room: [%d, %d]\nCC: [%d, %d]" % [room_x, room_y, cc_x, cc_y]
	FADE.color = Color(0, 0, 0, 0)
	if is_transitioning:
		if LR_Pressed:
			# Movimiento suave para portales L/R
			camera.position = camera.position.move_toward(target_camera_position, transition_speed * delta)

			# Verificar si la transición ha terminado
			if camera.position.distance_to(target_camera_position) < 1.0:
				camera.position = target_camera_position
				is_transitioning = false
				player.set_physics_process(true)
				load_npcs_for_current_room()
				load_portals_for_current_room()
				LR_Pressed = false
		else:
			# Movimiento seco para portales incrustados
			camera.position = target_camera_position
			is_transitioning = false
			player.set_physics_process(true)
			load_npcs_for_current_room()
			load_portals_for_current_room()
			
	
	# Mover el fondo junto con la cámara
	set_UI_pos()

func move_camera(new_position: Vector2):
	clear_npcs_and_portals()
	if not is_transitioning:
		target_camera_position = new_position
		player.set_physics_process(false)
		is_transitioning = true

		# Cambiar suavemente el color de fondo
		transition_bg_color()

	set_start_pos()

func transition_bg_color():
	var new_bg_color = Color(npcs_script.get_bg(room_x, room_y))
	if BG is ColorRect:
		var tween = create_tween()  # Crear un Tween nuevo
		tween.tween_property(BG, "color", new_bg_color, 1.0)  # Transición en 1 segundo
func load_bgm_for_current_room():
	var song = npcs_script.get_song(room_x,room_y)
	if current_song != song:
		current_song = song
		
		BGM.stream = load(bgm_sounds + song)  
		BGM.play()  
func load_portals_for_current_room():
	
	# Limpiar portales antiguos
	for portal in current_portals:
		portal.queue_free()
	current_portals.clear()

	# Obtener los portales del room actual
	var portals = npcs_script.get_portals(room_x, room_y)
	for portal_data in portals:
		# Cargar la escena Portal
		var portal_scene = preload("res://src/scenes/objects/portal/portal.tscn").instantiate()
		var room  = Vector2(portal_data["to"]["room"][0], portal_data["to"]["room"][1])
		var cc  = Vector2(portal_data["to"]["cc"][0], portal_data["to"]["cc"][1])
		# Configurar el portal con los datos del JSON
		portal_scene.setup_portal(  
			portal_data["x"],
			portal_data["y"],
			room, cc,
			tile_size,  # Pasar el valor de tile_size
			portal_data['w'],
			portal_data['h']
		)

		# Conectar las señales del portal
		portal_scene.connect("entered", Callable(self, "_on_portal_entered"))
		portal_scene.connect("exited", Callable(self, "_on_portal_exited"))
		portal_scene.connect("pressed", Callable(self, "_on_portal_pressed"))
		
		# Añadir el portal a la cámara
		camera.add_child(portal_scene)
		current_portals.append(portal_scene)

func _on_portal_entered():
	# Desactivar la capacidad de lanzar huevos
	
	print("El jugador no puede usar la Z.")

func _on_portal_exited():
	# Reactivar la capacidad de lanzar huevos
	
	print("El jugador puede usar la Z.")

func _on_portal_pressed():
	if is_transitioning:
		return
	player.set_physics_process(false)
	# Verificar si el jugador está dentro de un portal
	for portal in current_portals:
		if portal.overlaps_body(player):
			var target_room = portal.target_room
			var target_coords = portal.target_coords
			
			move_room(target_room, target_coords)
			break
func move_room(target_room, target_coords):
			# Realizar el fade out
			var tween = create_tween()
			tween.tween_property(FADE, "color:a", 1.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

			await tween.finished

			# Cambiar de room y posición
			room_x = target_room.x
			room_y = target_room.y
			screen_x = room_x * screen_width
			screen_y = room_y * screen_height

			var new_player_x = target_coords.x * tile_size
			var new_player_y = target_coords.y * tile_size

			player.position = Vector2(screen_x + new_player_x, screen_y + new_player_y)
			player.start_pos = Vector2(screen_x + screen_width / 2, screen_y + screen_height / 2)

			# Cargar NPCs y portales del nuevo room
			load_npcs_for_current_room()
			load_portals_for_current_room()

			# Mover la cámara
			move_camera(Vector2(screen_x, screen_y))

			# Realizar el fade in
			tween = create_tween()
			tween.tween_property(FADE, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func on_ActionKeyPressed():
	if is_transitioning:
		return

	# Verificar si el jugador está dentro de un portal incrustado
	for portal in current_portals:
		if portal.overlaps_body(player):
			var target_room = portal.target_room
			var target_coords = portal.target_coords

			# Realizar el fade out
			var tween = create_tween()
			tween.tween_property(FADE, "color:a", 1.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

			await tween.finished

			# Cambiar de room y posición
			room_x = target_room.x
			room_y = target_room.y
			screen_x = room_x * screen_width
			screen_y = room_y * screen_height

			var new_player_x = target_coords.x * tile_size
			var new_player_y = target_coords.y * tile_size

			player.position = Vector2(new_player_x, new_player_y)
			player.start_pos = Vector2(screen_x + screen_width / 2, screen_y + screen_height / 2)

			# Cargar NPCs y portales del nuevo room
			load_npcs_for_current_room()
			load_portals_for_current_room()

			# Realizar el fade in
			tween = create_tween()
			tween.tween_property(FADE, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

			break

func clear_npcs_and_portals():
	# Eliminar NPCs antiguos
	for npc in current_npcs:
		npc.queue_free()
	current_npcs.clear()

	# Eliminar portales antiguos
	for portal in current_portals:
		portal.queue_free()
	current_portals.clear()

func _on_portal_teleport(direction: String):
	LR_Pressed = true
	if is_transitioning:
		return

	# Verificar si estamos en la posición especial [-1, 0] con coordenadas [4, 3]
	if room_x == -1 and room_y == 0 and player.position.x / tile_size == 4 and player.position.y / tile_size == 3:
		# Teletransportar al jugador a [-1, -1] con coordenadas [2, 3]
		room_x = -1
		room_y = -1
		screen_x = -1 * screen_width
		screen_y = -1 * screen_height

		# Calcular la nueva posición del jugador dentro del nuevo room
		var new_player_x = 2 * tile_size
		var new_player_y = 3 * tile_size

		# Actualizar la posición del jugador
		player.position = Vector2(new_player_x, new_player_y)

		# Actualizar start_pos del jugador
		player.start_pos = Vector2(screen_x + screen_width / 2, screen_y + screen_height / 2)

		# Mover la cámara
		move_camera(Vector2(screen_x, screen_y))

		return

	# Transición normal
	match direction:
		"left":
			screen_x -= screen_width
			room_x -= 1
		"right":
			screen_x += screen_width
			player.position.x
			room_x += 1
		"up":
			screen_y -= screen_height
			player.position.y
			room_y -= 1
		"down":
			screen_y += screen_height
			player.position.y
			room_y += 1

	# Actualizar start_pos del jugador al cambiar de habitación
	player.start_pos = Vector2(screen_x + screen_width / 2, screen_y + screen_height / 2)
	move_camera(Vector2(screen_x, screen_y))

func load_npcs_for_current_room():
	var bg_color = npcs_script.get_bg(room_x, room_y)
	if BG is ColorRect:
		BG.color = Color(bg_color)  # Asigna el color inmediatamente
	var npcs_data = npcs_script.get_npc_list(room_x, room_y)
	for npc_info in npcs_data:
		# Cargar el recurso del NPC
		var npc_type = npc_info.get("type", "hen")
		var resource_path = "res://src/resources/npcs/" + npc_type + ".tres"
		var npc_resource = load(resource_path)
		if not npc_resource:
			printerr("Error: No se pudo cargar el recurso del NPC:", resource_path)
			continue

		# Instanciar el NPC
		var npc_instance = preload("res://src/scenes/objects/npc/Npc.tscn").instantiate()

		# Configurar la posición del NPC
		var world_x = (npc_info.get("location", [0, 0])[0] * tile_size)
		var world_y = screen_height - (npc_info.get("location", [0, 0])[1] * tile_size)
		npc_instance.position = Vector2(world_x, world_y)

		# Configurar el diálogo del NPC
		npc_instance.dialog_data = npc_info.get("dialog", "No hay diálogo disponible.")

		# Configurar la escala del NPC
		npc_instance.scale = Vector2(npc_info.get("scale", 1.0), npc_info.get("scale", 1.0))

		# Asignar el recurso del NPC
		npc_instance.npc_resource = npc_resource
		npc_instance.type = npc_type

		

		# Añadir el NPC a la escena
		$C/Game/SVP/Camera/Npcs.add_child(npc_instance)
		current_npcs.append(npc_instance)
	load_bgm_for_current_room()

func validate_portal(b):
	return "Hen" in b.to_string() and not is_transitioning

func on_Left_teleport(body: Node2D) -> void:
	if validate_portal(body):
		_on_portal_teleport("left")

func on_Right_teleport(body: Node2D) -> void:
	if validate_portal(body):
		_on_portal_teleport("right")

func on_Down_teleport(body: Node2D) -> void:
	if validate_portal(body):
		_on_portal_teleport("down")

func on_Up_teleport(body: Node2D) -> void:
	if validate_portal(body):
		_on_portal_teleport("up")


func _on_teleport(location: String) -> void:
	var values = location.split(",", false)
	
	if values.size() != 4:
		push_error("Formato incorrecto. Usa: room_x,room_y,cc_x,cc_y")
		return

	var room_x = int(values[0])
	var room_y = int(values[1])
	var cc_x = int(values[2])
	var cc_y = int(values[3])
	move_room(Vector2(room_x,room_y), Vector2(cc_x,cc_y))
