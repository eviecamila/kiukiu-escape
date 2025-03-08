extends Node2D

class_name RoomParser

# Variables de configuración
@export var tileset: TileSet
@export var npc_sprite_sheet: Texture2D
@export var npc_scene: PackedScene  # Escena del NPC

# Contenedor de rooms
var rooms_container: Node2D

func _ready():
	rooms_container = Node2D.new()
	add_child(rooms_container)
	load_room(0)

func load_room(room_id: int):
	var room_data = get_room_data(room_id)
	var room_node = Node2D.new()
	room_node.name = "Room_%s" % room_id
	
	generate_blocks(room_node, room_data.blocks)
	create_portals(room_node, room_data.portals)
	spawn_npcs(room_node, room_data.npcs)
	position_player(room_data.startpos)
	
	rooms_container.add_child(room_node)

func get_room_data(room_id: int) -> Dictionary:
	# Implementa la carga desde un archivo JSON o base de datos
	# Ejemplo de datos estáticos:
	return {
		"blocks": {
			"layer1": {
				"sky": {"custom": [0,34,5,2,4]},
				"dirt": {"bits": [0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0], "fill_horizontal": false}
			}
		},
		"portals": [],
		"npes": [],
		"startpos": {"x": 0, "y": 0, "direction": true}
	}

func generate_blocks(parent: Node, blocks_data: Dictionary):
	for layer_name in blocks_data:
		var layer_data = blocks_data[layer_name]
		var tilemap = TileMap.new()
		tilemap.tile_set = tileset
		tilemap.name = layer_name
		
		for block_type in layer_data:
			var block_config = layer_data[block_type]
			
			if block_type == "sky":
				if "custom" in block_config:
					generate_custom_blocks(tilemap, block_config["custom"])
			else:
				var bits = block_config["bits"]
				var fill_horizontal = block_config["fill_horizontal"]
				
				for i in range(16):
					if bits[i] == 1:
						var x = i if fill_horizontal else 0
						var y = 0
						if block_type == "dirt":
							y = 8
						elif block_type == "tree_top":
							y = 4
						tilemap.set_cell(Vector2i(x, y), 0)  # Usar Vector2i
		parent.add_child(tilemap)

func generate_custom_blocks(parent: TileMap, custom_data: Array):
	var filling = true
	var current_x = 0
	var current_y = 0
	
	for value in custom_data:
		while value > 0:
			if filling:
				parent.set_cell(Vector2i(current_x, current_y), 1)  # Usar Vector2i
			current_x += 1
			if current_x >= 16:
				current_x = 0
				current_y += 1
			value -= 1
		filling = !filling

func create_portals(parent: Node, portals_data: Array):
	for portal in portals_data:
		var area = Area2D.new()
		area.connect("body_entered", Callable(self, "_on_portal_entered").bind(portal.room_id))
		
		if portal.area.type:
			var rect_shape = RectangleShape2D.new()
			rect_shape.extents = Vector2(0.5, portal.area.thickness)
			var collision = CollisionShape2D.new()
			collision.shape = rect_shape
			area.add_child(collision)
		else:
			var line_shape = SegmentShape2D.new()
			line_shape.a = Vector2(portal.area.coords.x1, portal.area.coords.y1)
			line_shape.b = Vector2(portal.area.coords.x2, portal.area.coords.y2)
		
		area.position = Vector2(portal.area.coords.x1, portal.area.coords.y1)
		parent.add_child(area)

func spawn_npcs(parent: Node, npcs_data: Array):
	for npc in npcs_data:
		var npc_node = npc_scene.instance()  # Instancia desde el recurso
		if npc_node.is_instance_valid():
			if npc_node.has_method("set_dialog_data"):
				npc_node.set_dialog_data(npc.dialog)
			if npc_node.has_method("set_item_data"):
				npc_node.set_item_data(npc.item)
			npc_node.position = Vector2(npc.position.x * 16, npc.position.y * 16)
			parent.add_child(npc_node)

func position_player(startpos: Dictionary):
	# Implementa la lógica para posicionar al jugador
	pass
