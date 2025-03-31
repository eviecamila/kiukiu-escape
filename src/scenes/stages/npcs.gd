extends Node

const npc_list = {
	0: {
		0: {
			"bg": "87CEEB",
			"npc_list": [
				{
					"dialog": ["Soy la coco coco", "Follame, Evie!", "no te creas we, es cura"],
					"location": [2, 2.5],
					"type": "hen"
				}
			],
			"portals":[
				#portal de la caseta 2 al subterraneo
				#{'x':28, 'y':15, 'w':2, 'h': 2, "to":{"room":[-1,1],"cc":[3, 6]}}
			]
		}
	},
	-1: {
		0: {
			"bg": "5555ff",
			"npc_list": [
				{
					"dialog": ["Soy la coco coco", "Follame, Evie!", "no te creas we, es cura"],
					"location": [8, 2],
					"type": "hen"
				},
				{
					"dialog": ["Kiu Kiu *>"],
					"location": [0, 3],
					"type": "hen"
				}
			],
			"portals":[
				{'x':6, 'y':15, 'w':2, 'h': 2, "to":{"room":[-1,1],"cc":[3, 6]}}
			]
		},
		1: {
			"bg": "FFD700",  # Color de fondo para el nuevo room [-1, -1]
			"npc_list": [
				{
					"dialog": ["COCO COCO! Soy una gallina feliz.", "¿Quieres un huevo?"],
					"location": [3, 6],  # Ubicación dentro del room [-1, -1]
					"type": "hen"  # Tipo de NPC: gallina
				}
			]
		}
	},
	-2: {}
}

# Función para obtener el color de fondo de un room
func get_bg(room_x: int, room_y: int) -> String:
	if npc_list.has(room_x) and npc_list[room_x].has(room_y):
		return npc_list[room_x][room_y].get("bg", "87CEEB")
	return "87CEEB"

# Función para obtener la lista de NPCs de un room
func get_npc_list(room_x: int, room_y: int) -> Array:
	if npc_list.has(room_x) and npc_list[room_x].has(room_y):
		return npc_list[room_x][room_y].get("npc_list", [])
	return []

# Función para obtener los portales de un room
func get_portals(room_x: int, room_y: int) -> Array:
	if npc_list.has(room_x) and npc_list[room_x].has(room_y):
		return npc_list[room_x][room_y].get("portals", [])
	return []
