extends Node

@export var level = 0
var estar_chingando = not PlayerData.debug

const songs = [
	"overworld.ogg",
	"fanfare_loop.ogg"
]
var data:Dictionary ={}
func _ready():
	if level:data = get_level_data(level)
func setup():
	data = get_level_data(level)
func get_level_data(lvl:int):
	if level:
		var stage = load(str("res://src/scenes/stages/levels/w%d/map.tscn"%[lvl])).instantiate()
		return stage.stage_data
# Función para obtener el color de fondo de un room
func get_bg(room_x: int, room_y: int) -> String:
	if data.has(room_x) and data[room_x].has(room_y):
		return data[room_x][room_y].get("bg", "87CEEB")
	return "87CEEB"

func get_song(x, y): 
	if not estar_chingando: return ""
	x = int(x)  # Convierte a entero
	y = int(y)  # Convierte a entero

	if data.has(x):
		print("Room X encontrado:", x)
		if data[x].has(y):
			print("Room Y encontrado:", y, "BGM:", data[x][y].get("bgm", songs[0]))
			return data[x][y].get("bgm", songs[0])
		else:
			print("No se encontró la subclave Y:", y)
	else:
		print("No se encontró la clave X:", x)
	return songs[0]

# Función para obtener la lista de NPCs de un room
func get_npc_list(room_x: int, room_y: int) -> Array:
	if data.has(room_x) and data[room_x].has(room_y):
		return data[room_x][room_y].get("npc_list", [])
	return []

func get_portal_metadata(p):
	return 	{"x":p["x"], "y":p["y"], "w":p["w"], "h": p["h"], "to":p["to"]}
	

# Función para obtener los portales de un room
func get_portals(room_x: int, room_y: int) -> Array:
	if data.has(room_x) and data[room_x].has(room_y):
		var portals = data[room_x][room_y].get("portals", [])
		var p_list = []
		for p in portals:
			var req = p.get("req", false)
			if req:
				var jmp = req.get("jumps", 0)
				if jmp == 0  or jmp <= PlayerData.max_jumps:
					p_list.append(p)
			else:
				p_list.append(p)
		return p_list
	return []
