extends Node2D

class_name RoomParser

const obj_path = "res://src/scenes/objects/"

# Variables de configuración
@export var tileset: TileSet
@export var npc_sprite_sheet: Texture2D
@onready var npc_scene: PackedScene = preload("%splayer/Hen.tscn" % obj_path)  #mi gallina siempre ta cacaraqueando
@onready var portal_scene: PackedScene = preload(obj_path + "blocks/portal.tscn")  #escena del portal
@onready var border_scene: PackedScene = preload(obj_path + "blocks/invisible_border.tscn")

var rooms = {
	"rooms": {
		"1": {
		"portals": [
			{
				"room_id": 2,
				"area": {
					"type": "rectangle",
					"x": 100,
					"y": 200,
					"width": 32,
					"height": 16
				},
				"position": { "x": 50, "y": 100 }
			},
			{
				"room_id": 3,
				"area": {
					"type": "line",
					"coords": {
						"x1": 300,
						"y1": 200,
						"x2": 300,
						"y2": 400
					}
				},
				"position": { "x": 150, "y": 200 }
			}
		],
		"borders": [
			{ "x1": 0, "x2": 1900, "y1": 480, "y2": 480 }
		],
		"spawn": { "x": 950, "y": 240 } 
	},
		"2": {
			"portals": [
				{
					"room_id": 1,
					"area": {
						"type": "line",
						"coords": {
							"x1": 100,
							"y1": 100,
							"x2": 100,
							"y2": 300
						}
					},
					"position": { "x": 600, "y": 200 }
				},
				{
					"room_id": 4,
					"area": {
						"type": "rectangle",
						"x": 500,
						"y": 50,
						"width": 32,
						"height": 32
					},
					"position": { "x": 516, "y": 150 }
				}
			],
			"borders": [
				{ "x1": 640, "x2": 640, "y1": 0, "y2": 480 },
				{ "x1": 0, "x2": 640, "y1": 0, "y2": 0 }
			],
			"spawn": { "x": 100, "y": 300 }
		},
		"3": {
			"portals": [
				{
					"room_id": 1,
					"area": {
						"type": "rectangle",
						"x": 200,
						"y": 300,
						"width": 48,
						"height": 16
					},
					"position": { "x": 400, "y": 300 }
				},
				{
					"room_id": 5,
					"area": {
						"type": "line",
						"coords": {
							"x1": 600,
							"y1": 200,
							"x2": 600,
							"y2": 400
						}
					},
					"position": { "x": 50, "y": 200 }
				}
			],
			"borders": [
				{ "x1": 0, "x2": 640, "y1": 480, "y2": 480 },
				{ "x1": 640, "x2": 640, "y1": 0, "y2": 480 }
			],
			"spawn": { "x": 320, "y": 350 }
		},
		"4": {
			"portals": [
				{
					"room_id": 2,
					"area": {
						"type": "rectangle",
						"x": 50,
						"y": 50,
						"width": 32,
						"height": 32
					},
					"position": { "x": 320, "y": 240 }
				},
				{
					"room_id": 5,
					"area": {
						"type": "line",
						"coords": {
							"x1": 320,
							"y1": 0,
							"x2": 320,
							"y2": 480
						}
					},
					"position": { "x": 600, "y": 240 }
				}
			],
			"borders": [
				{ "x1": 0, "x2": 640, "y1": 480, "y2": 480 },
				{ "x1": 0, "x2": 0, "y1": 0, "y2": 480 }
			],
			"spawn": { "x": 100, "y": 240 }
		},
		"5": {
			"portals": [
				{
					"room_id": 3,
					"area": {
						"type": "rectangle",
						"x": 100,
						"y": 100,
						"width": 64,
						"height": 32
					},
					"position": { "x": 320, "y": 400 }
				},
				{
					"room_id": 4,
					"area": {
						"type": "line",
						"coords": {
							"x1": 0,
							"y1": 240,
							"x2": 640,
							"y2": 240
						}
					},
					"position": { "x": 320, "y": 100 }
				}
			],
			"borders": [
				{ "x1": 0, "x2": 640, "y1": 0, "y2": 0 },
				{ "x1": 640, "x2": 640, "y1": 0, "y2": 480 }
			],
			"spawn": { "x": 500, "y": 200 }
		}
	}
}

var rooms_container: Node2D

func _ready():
	# Crear el contenedor de habitaciones
	rooms_container = Node2D.new()
	add_child(rooms_container)
	
	# Cargar la primera habitación
	load_room(1)

func load_room(room_id: int):
	var room_data = get_room_data(room_id)
	var room_node = Node2D.new()
	room_node.name = "Room_%s" % room_id
	
	# Crear portales, bordes y punto de spawn
	create_portals(room_node, room_data.portals)
	create_borders(room_node, room_data.borders)
	create_spawn_point(room_node, room_data.spawn)
	
	# Instanciar y posicionar al jugador/NPC en el punto de spawn
	position_player(room_data.spawn)
	
	# Agregar la habitación al Viewport
	var viewport_game_world = $ViewportContainer/Viewport/GameWorld
	if not viewport_game_world:
		print("Error: El nodo 'GameWorld' no está asignado en el Viewport.")
		return
	
	viewport_game_world.add_child(room_node)

func position_player(startpos: Dictionary):
	if not npc_scene:
		print("Error: La escena del NPC no está asignada.")
		return

	# Eliminar cualquier NPC existente
	for existing_npc in get_tree().get_nodes_in_group("player"):
		existing_npc.queue_free()

	# Crear una nueva instancia del NPC
	var player = npc_scene.instantiate()
	player.position = Vector2(startpos.x, startpos.y)
	player.add_to_group("player")
	
	# Agregar la gallina al Viewport
	var viewport_game_world = $ViewportContainer/Viewport/GameWorld
	if viewport_game_world:
		viewport_game_world.add_child(player)
	else:
		print("Error: El nodo 'GameWorld' no está asignado en el Viewport.")
