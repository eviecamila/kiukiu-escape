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

@onready var camera = $C/SVPC/SVP/Camera
@onready var player = $C/SVPC/SVP/Node2/Hen
@onready var npcs_script = get_node("/root/Stage/C/SVPC/SVP/Camera/Npcs")  # Referencia al nodo con npcs.gd

func _ready():
	camera.offset.x = 0
	is_transitioning = false
	load_npcs_for_current_room()
	set_start_pos()
	
func set_start_pos():
	player.start_pos = Vector2(player.position.x, player.position.y + 20)
	
func _process(delta: float):
	if is_transitioning:
		camera.position = camera.position.move_toward(target_camera_position, transition_speed * delta)
		
		# Cuando termina la transición
		if camera.position.distance_to(target_camera_position) < 1.0:
			camera.position = target_camera_position
			is_transitioning = false
			player.set_physics_process(true)
			
			# Eliminar NPCs antiguos y cargar nuevos
			load_npcs_for_current_room()

func move_camera(new_position: Vector2):
	clear_npcs()
	if not is_transitioning:
		target_camera_position = new_position
		player.set_physics_process(false)
		is_transitioning = true
	set_start_pos()

func _on_portal_entered(direction: String):
	if is_transitioning:
		return

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

func clear_npcs():
	for npc in current_npcs:
		npc.queue_free()
	current_npcs.clear()

func load_npcs_for_current_room():
	var npcs_data = npcs_script.get_npc_list(room_x, room_y)

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
		_on_portal_entered("left")

func on_Right_teleport(body: Node2D) -> void:
	if "Hen" in body.to_string() and not is_transitioning:
		_on_portal_entered("right")
