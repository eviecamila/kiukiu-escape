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
@onready var camera = $C/SVPC/SVP/Camera
@onready var player = $C/SVPC/SVP/Node2/Hen
@onready var BG = $C/SVPC/SVP/BG
@onready var BGM = $BGM
@onready var FADE = $C/SVPC/SVP/Fade
@onready var npcs_script = get_node("/root/Stage/C/SVPC/SVP/Camera/Npcs")  # Referencia al nodo con npcs.gd
@onready var bgm_sounds = "res://assets/audio/soundtrack/"  # Referencia al nodo con npcs.gd

func _ready():
	#get_tree().set_debug_collisions_hint(true) 
	camera.offset.x = 0
	is_transitioning = false
	load_npcs_for_current_room()
	load_portals_for_current_room()
	set_start_pos()

func set_start_pos():
	player.start_pos = Vector2(player.position.x, player.position.y + 20)

func _process(delta: float):
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
	BG.position = camera.position
	FADE.position = camera.position

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
	prints("well, changing song to", song)
	prints("tamos en: X:", room_x, "Y:", room_y)
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
	player.can_throw = false
	print("El jugador ya no puede lanzar huevos.")

func _on_portal_exited():
	# Reactivar la capacidad de lanzar huevos
	player.can_throw = true
	print("El jugador puede lanzar huevos nuevamente.")

func _on_portal_pressed():
	if is_transitioning:
		return
	player.set_physics_process(false)
	# Verificar si el jugador está dentro de un portal
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

			break

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
			player.position.x -= 80
			room_x -= 1
		"right":
			screen_x += screen_width
			player.position.x += 80
			room_x += 1
		"up":
			screen_y -= screen_height
			player.position.y -= 80
			room_y -= 1
		"down":
			screen_y += screen_height
			player.position.y += 80
			room_y += 1

	# Actualizar start_pos del jugador al cambiar de habitación
	player.start_pos = Vector2(screen_x + screen_width / 2, screen_y + screen_height / 2)
	move_camera(Vector2(screen_x, screen_y))

func load_npcs_for_current_room():
	load_bgm_for_current_room()
	var npcs_data = npcs_script.get_npc_list(room_x, room_y)
	var bg_color = npcs_script.get_bg(room_x, room_y)

	if BG is ColorRect:
		BG.color = Color(bg_color)  # Asigna el color inmediatamente

	for npc_info in npcs_data:
		var npc_instance = preload("res://src/scenes/objects/npc/Npc.tscn").instantiate()

		# Asegurarse de que las coordenadas tengan valores predeterminados
		var world_x = (npc_info.get("location", [0, 0])[0] * tile_size)
		var world_y = screen_height - (npc_info.get("location", [0, 0])[1] * tile_size)

		npc_instance.position = Vector2(world_x, world_y)

		# Asegurarse de que el diálogo tenga un valor predeterminado
		npc_instance.dialog_data = npc_info.get("dialog", ["No hay diálogo disponible."])

		# Asegurarse de que la escala tenga un valor predeterminado
		npc_instance.scale = Vector2(npc_info.get("scale", 1.0), npc_info.get("scale", 1.0))

		# Asegurarse de que el tipo tenga un valor predeterminado
		npc_instance.type = npc_info.get("type", "hen")

		# Añadir el NPC a la escena
		$C/SVPC/SVP/Camera/Npcs.add_child(npc_instance)
		current_npcs.append(npc_instance)

func on_Left_teleport(body: Node2D) -> void:
	if "Hen" in body.to_string() and not is_transitioning:
		_on_portal_teleport("left")

func on_Right_teleport(body: Node2D) -> void:
	if "Hen" in body.to_string() and not is_transitioning:
		_on_portal_teleport("right")
